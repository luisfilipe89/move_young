import json

with open("lib/python_scraper/upcoming_events.json", encoding="utf-8") as f:
    events = json.load(f)

dart_lines = ["import '../models/event.dart';\n",
              "final List<Event> mockEvents = [\n"]

for e in events:
    dart_lines.append(f"  Event(\n"
                      f"    title: '''{e['title']}''',\n"
                      f"    url: '{e['url']}',\n"
                      f"    organizer: '''{e['organizer']}''',\n"
                      f"    location: '''{e['location']}''',\n"
                      f"    targetGroup: '''{e['target_group']}''',\n"
                      f"    dateTime: '''{e['date_time']}''',\n"
                      f"    cost: '''{e['cost']}''',\n"
                      f"  ),\n")

dart_lines.append("];\n")

with open("mock_events.dart", "w", encoding="utf-8") as f:
    f.writelines(dart_lines)

print("✅ Dart file generated: mock_events.dart")
