extends Node
## ============================================================================
## UNIVERSAL SAVE SYSTEM - Wiederverwendbar für JEDES Godot Spiel
## ============================================================================
## 
## VERWENDUNG:
## 1. Als Autoload hinzufügen: Project Settings -> Autoload -> "SaveSystem"
## 2. In deinem Spiel einen SaveDataCollector erstellen (siehe Beispiel)
## 3. Speichern: SaveSystem.save_game(slot_id, my_data_dictionary)
## 4. Laden: var data = SaveSystem.load_game(slot_id)
##
## Dieses Script ist komplett spielunabhängig und kann 1:1 in andere Projekte
## kopiert werden!
## ============================================================================

class_name UniversalSaveSystem

## Signale für externe Systeme
signal save_started(slot_id: int)
signal save_completed(slot_id: int, success: bool)
signal load_started(slot_id: int)
signal load_completed(slot_id: int, data: Dictionary)
signal load_failed(slot_id: int, error: String)
signal slot_deleted(slot_id: int)

## Konfiguration (kann von außen geändert werden)
@export var save_directory: String = "user://saves/"
@export var save_file_prefix: String = "slot_"
@export var save_file_extension: String = ".sav"
@export var max_save_slots: int = 5
@export var encryption_enabled: bool = true
@export var compression_enabled: bool = true
@export var encryption_password: String = "change_this_password_123"

## Interne Variablen
var current_slot: int = -1
var last_save_data: Dictionary = {}


## ============================================================================
## INITIALISIERUNG
## ============================================================================

func _ready() -> void:
	_ensure_save_directory_exists()
	print("🔧 UniversalSaveSystem initialisiert")
	print("   📁 Verzeichnis: " + save_directory)
	print("   🔒 Verschlüsselung: " + ("AN" if encryption_enabled else "AUS"))
	print("   📦 Kompression: " + ("AN" if compression_enabled else "AUS"))


func _ensure_save_directory_exists() -> void:
	var dir = DirAccess.open("user://")
	if dir:
		var folder_name = save_directory.replace("user://", "").trim_suffix("/")
		if not dir.dir_exists(folder_name):
			var result = dir.make_dir_recursive(folder_name)
			if result == OK:
				print("📁 Save-Verzeichnis erstellt: " + save_directory)
			else:
				push_error("❌ Konnte Save-Verzeichnis nicht erstellen: " + str(result))


## ============================================================================
## HAUPTFUNKTIONEN
## ============================================================================

## Speichert ein Dictionary in einem Slot
## @param slot_id: Slot-Nummer (0 bis max_save_slots-1)
## @param data: Dictionary mit beliebigen Spieldaten
## @return: true bei Erfolg, false bei Fehler
func save_game(slot_id: int, data: Dictionary) -> bool:
	if not _is_valid_slot(slot_id):
		push_error("❌ Ungültiger Slot: " + str(slot_id))
		save_completed.emit(slot_id, false)
		return false
	
	save_started.emit(slot_id)
	
	# Füge System-Metadaten hinzu
	var save_package = _create_save_package(slot_id, data)
	
	# Konvertiere zu Bytes
	var bytes = _serialize_data(save_package)
	if bytes.is_empty():
		push_error("❌ Serialisierung fehlgeschlagen")
		save_completed.emit(slot_id, false)
		return false
	
	# Komprimiere falls aktiviert
	if compression_enabled:
		bytes = _compress_data(bytes)
	
	# Speichere Datei
	var success = _write_to_file(slot_id, bytes)
	
	if success:
		current_slot = slot_id
		last_save_data = data.duplicate(true)
		print("✅ Spiel gespeichert in Slot %d (%d bytes)" % [slot_id, bytes.size()])
	
	save_completed.emit(slot_id, success)
	return success


## Lädt ein Dictionary aus einem Slot
## @param slot_id: Slot-Nummer (0 bis max_save_slots-1)
## @return: Dictionary mit Spieldaten oder leeres Dictionary bei Fehler
func load_game(slot_id: int) -> Dictionary:
	if not _is_valid_slot(slot_id):
		push_error("❌ Ungültiger Slot: " + str(slot_id))
		load_failed.emit(slot_id, "Ungültiger Slot")
		return {}
	
	if not slot_exists(slot_id):
		push_warning("⚠️ Kein Save in Slot " + str(slot_id))
		load_failed.emit(slot_id, "Slot existiert nicht")
		return {}
	
	load_started.emit(slot_id)
	
	# Lese Datei
	var bytes = _read_from_file(slot_id)
	if bytes.is_empty():
		push_error("❌ Konnte Datei nicht lesen")
		load_failed.emit(slot_id, "Datei konnte nicht gelesen werden")
		return {}
	
	# Dekomprimiere falls nötig
	if compression_enabled:
		bytes = _decompress_data(bytes)
		if bytes.is_empty():
			push_error("❌ Dekompression fehlgeschlagen")
			load_failed.emit(slot_id, "Dekompression fehlgeschlagen")
			return {}
	
	# Deserialisiere
	var save_package = _deserialize_data(bytes)
	if save_package.is_empty():
		push_error("❌ Deserialisierung fehlgeschlagen")
		load_failed.emit(slot_id, "Deserialisierung fehlgeschlagen")
		return {}
	
	# Validiere Save-Paket
	if not _validate_save_package(save_package):
		push_error("❌ Ungültiges Save-Format")
		load_failed.emit(slot_id, "Ungültiges Save-Format")
		return {}
	
	# Extrahiere Spieldaten
	var game_data = save_package.get("game_data", {})
	
	current_slot = slot_id
	last_save_data = game_data.duplicate(true)
	
	print("✅ Spiel geladen aus Slot %d" % slot_id)
	load_completed.emit(slot_id, game_data)
	return game_data


# Creates a new save and sets the correct curent_slot 
func create_new_save(character_name: String):
	var new_slot_id = count_used_slots()
	if not _is_valid_slot(new_slot_id):
		print("Error Creating new Character")
		push_error("Maximum Limit for Saves are reached")
	current_slot = count_used_slots()
	var data = DataCollector.collect_all_game_data()
	data["character"]["name"] = character_name
	save_game(current_slot, data)


func count_used_slots() -> int:
	var counter = 0
	var slots = get_all_slots()
	for slot in slots:
		if slot["exists"]:
			counter += 1
		
	return counter

## Löscht einen Save-Slot
## @param slot_id: Slot-Nummer
## @return: true bei Erfolg
func delete_slot(slot_id: int) -> bool:
	if not slot_exists(slot_id):
		return false
	
	var path = _get_slot_path(slot_id)
	var dir = DirAccess.open(save_directory)
	
	if dir:
		var result = dir.remove(path)
		if result == OK:
			print("🗑️ Slot %d gelöscht" % slot_id)
			slot_deleted.emit(slot_id)
			return true
	
	return false


## Prüft ob ein Slot existiert
## @param slot_id: Slot-Nummer
## @return: true wenn Slot existiert
func slot_exists(slot_id: int) -> bool:
	return FileAccess.file_exists(_get_slot_path(slot_id))


## Gibt Informationen über alle Slots zurück
## @return: Array mit Slot-Informationen
func get_all_slots() -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	
	for i in range(max_save_slots):
		var slot_info = get_slot_info(i)
		slots.append(slot_info)
	
	return slots


## Gibt Informationen über einen einzelnen Slot
## @param slot_id: Slot-Nummer
## @return: Dictionary mit Slot-Info
func get_slot_info(slot_id: int) -> Dictionary:
	var info: Dictionary = {
		"slot_id": slot_id,
		"exists": false,
		"file_size": 0,
		"timestamp": 0,
		"metadata": {}
	}
	
	if not slot_exists(slot_id):
		return info
	
	info["exists"] = true
	info["file_size"] = _get_file_size(slot_id)
	
	# Lade nur Metadaten (schneller als komplettes Laden)
	var metadata = get_slot_metadata(slot_id)
	if not metadata.is_empty():
		info["timestamp"] = metadata.get("timestamp", 0)
		info["metadata"] = metadata.get("user_metadata", {})
	
	return info


## Gibt nur die Metadaten eines Slots zurück (ohne Spieldaten)
## @param slot_id: Slot-Nummer
## @return: Dictionary mit Metadaten
func get_slot_metadata(slot_id: int) -> Dictionary:
	if not slot_exists(slot_id):
		return {}
	
	var bytes = _read_from_file(slot_id)
	if bytes.is_empty():
		return {}
	
	if compression_enabled:
		bytes = _decompress_data(bytes)
	
	var save_package = _deserialize_data(bytes)
	if save_package.is_empty():
		return {}
	
	# Gebe nur Metadaten zurück, nicht die Spieldaten
	return {
		"version": save_package.get("version", ""),
		"timestamp": save_package.get("timestamp", 0),
		"slot_id": save_package.get("slot_id", -1),
		"user_metadata": save_package.get("user_metadata", {})
	}


## ============================================================================
## HILFSFUNKTIONEN
## ============================================================================

func _is_valid_slot(slot_id: int) -> bool:
	return slot_id >= 0 and slot_id < max_save_slots


func _get_slot_path(slot_id: int) -> String:
	return save_directory + save_file_prefix + str(slot_id) + save_file_extension


func _get_file_size(slot_id: int) -> int:
	var file = FileAccess.open(_get_slot_path(slot_id), FileAccess.READ)
	if file:
		var size = file.get_length()
		file.close()
		return size
	return 0


## Erstellt ein Save-Paket mit Metadaten
func _create_save_package(slot_id: int, game_data: Dictionary) -> Dictionary:
	return {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"slot_id": slot_id,
		"godot_version": Engine.get_version_info(),
		"user_metadata": game_data.get("_metadata", {}),  # Optionale Metadaten vom Spiel
		"game_data": game_data
	}


## Validiert ein geladenes Save-Paket
func _validate_save_package(package: Dictionary) -> bool:
	return package.has("version") and package.has("game_data")


## ============================================================================
## SERIALISIERUNG
## ============================================================================

func _serialize_data(data: Dictionary) -> PackedByteArray:
	var json_string = JSON.stringify(data)
	return json_string.to_utf8_buffer()


func _deserialize_data(bytes: PackedByteArray) -> Dictionary:
	var json_string = bytes.get_string_from_utf8()
	var json = JSON.new()
	
	if json.parse(json_string) != OK:
		push_error("JSON Parse Fehler: " + json.get_error_message())
		return {}
	
	var data = json.get_data()
	if typeof(data) == TYPE_DICTIONARY:
		return data
	
	return {}


## ============================================================================
## KOMPRESSION
## ============================================================================

func _compress_data(bytes: PackedByteArray) -> PackedByteArray:
	var compressed = bytes.compress(FileAccess.COMPRESSION_GZIP)
	var ratio = float(compressed.size()) / float(bytes.size()) * 100.0
	print("📦 Komprimiert: %d -> %d bytes (%.1f%%)" % [bytes.size(), compressed.size(), ratio])
	return compressed


func _decompress_data(bytes: PackedByteArray) -> PackedByteArray:
	# Versuche mit verschiedenen Methoden zu dekomprimieren
	var decompressed = bytes.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	
	if decompressed.is_empty():
		push_error("Dekompression fehlgeschlagen")
	
	return decompressed


## ============================================================================
## DATEI I/O
## ============================================================================

func _write_to_file(slot_id: int, data: PackedByteArray) -> bool:
	var path = _get_slot_path(slot_id)
	var file: FileAccess
	
	if encryption_enabled:
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, encryption_password)
	else:
		file = FileAccess.open(path, FileAccess.WRITE)
	
	if file == null:
		var error = FileAccess.get_open_error()
		push_error("Konnte Datei nicht öffnen: " + str(error))
		return false
	
	file.store_buffer(data)
	file.close()
	return true


func _read_from_file(slot_id: int) -> PackedByteArray:
	var path = _get_slot_path(slot_id)
	var file: FileAccess
	
	if encryption_enabled:
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, encryption_password)
	else:
		file = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		var error = FileAccess.get_open_error()
		push_error("Konnte Datei nicht lesen: " + str(error))
		return PackedByteArray()
	
	var data = file.get_buffer(file.get_length())
	file.close()
	return data


## ============================================================================
## ZUSATZFUNKTIONEN
## ============================================================================

## Gibt den aktuell geladenen Slot zurück
func get_current_slot() -> int:
	return current_slot


## Gibt die letzten geladenen Daten zurück
func get_last_save_data() -> Dictionary:
	return last_save_data


## Exportiert einen Save als Backup
func export_save(slot_id: int, export_path: String) -> bool:
	if not slot_exists(slot_id):
		return false
	
	var source_path = _get_slot_path(slot_id)
	var dir = DirAccess.open(save_directory)
	
	if dir:
		return dir.copy(source_path, export_path) == OK
	
	return false


## Importiert einen Save
func import_save(import_path: String, target_slot: int) -> bool:
	if not FileAccess.file_exists(import_path):
		return false
	
	var target_path = _get_slot_path(target_slot)
	var dir = DirAccess.open("user://")
	
	if dir:
		return dir.copy(import_path, target_path) == OK
	
	return false


## Gibt Statistiken zurück
func get_statistics() -> Dictionary:
	var used_slots = 0
	var total_size = 0
	
	for i in range(max_save_slots):
		if slot_exists(i):
			used_slots += 1
			total_size += _get_file_size(i)
	
	return {
		"max_slots": max_save_slots,
		"used_slots": used_slots,
		"total_size_bytes": total_size,
		"encryption": encryption_enabled,
		"compression": compression_enabled
	}
