extends Control

@export var table: VBoxContainer

func _ready() -> void:
	var grist_client: GristClient = GristClient.new(self)
	var orgs: ResponseDto = await grist_client.get_orgs()
	if not orgs.ok: return
	for org in orgs.data:
		var org_id: String = str(int(org.id))
		var workspaces: ResponseDto = await grist_client.get_org_workspaces(org_id)
		if not workspaces.ok: continue
		for workspace in workspaces.data:
			var docs: Array = workspace.docs
			for doc in docs:
				var doc_id: String = doc.id
				var tables: ResponseDto = await grist_client.get_tables(doc_id)
				if not tables.ok: continue
				for table in tables.data.tables:
					var table_id: String = table.id
					var records: ResponseDto = await grist_client.get_records(doc_id, table_id)
					if not records.ok: continue
					for record in records.data.records:
						if not record.fields.has("Name") or not record.fields.has("Highscore") or not record.fields.has("Date"): continue
						print(record)
						var row: HBoxContainer = HBoxContainer.new()
						var label_name: Label = Label.new()
						label_name.text = record.fields.Name
						label_name.custom_minimum_size = Vector2(256, 0)
						var label_score: Label = Label.new()
						label_score.text = str(int(record.fields.Highscore))
						label_score.custom_minimum_size = Vector2(256, 0)
						var label_date: Label = Label.new()
						label_date.text = Time.get_datetime_string_from_unix_time(int(record.fields.Date), true)
						label_date.custom_minimum_size = Vector2(256, 0)
						
						row.add_child(label_name)
						row.add_child(label_score)
						row.add_child(label_date)
						self.table.add_child(row)
