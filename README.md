# Personal AI Assistant

This project is a personal AI assistant intended to act in aiding human executive function. 

It is a work in progress and is currently in the early stages of development.

## Planned Features

#### MVP
- [X] Basic conversation (Using OpenAI's Assistant API)
- [ ] Text-to-speech
- [ ] Voice recognition
- [ ] Executive Data Aggregation
  - Stores data about the user's schedule and tasks in a database. This is necessary for the assistant to be able to analyze subtle differences in-between user sessions.
  - [ ] Apple Ecosystem Integration
    - [ ] Apple Reminders
    - [ ] Apple Calendar 
  - [ ] Google Ecosystem Integration
    - [ ] Google Calendar
    - [ ] Google Tasks
  - [ ] Microsoft Ecosystem Integration
    - [ ] Microsoft To-Do
    - [ ] Microsoft Calendar
- [ ] Create a mechanism for the assistant to be able to add, remove, and modify tasks and events on all integrated platforms.
  - [ ] This may be through the use of Microsoft's Python Library AutoGen.
    - Python can be run in Dart using the (`python_ffi`)[https://pub.dev/packages/python_ffi] library.
  
- [ ] Executive Planning
  - [ ] Daily Briefing
    - [ ] Uses data aggregation to provide a daily briefing of the user's schedule and tasks
  - [ ] Task Management
    - [ ] Ability to add, remove, and modify tasks on all integrated platforms
    - [ ] Ability to customize preferences for default task platform as well as default task list.
  - [ ] Calendar Management
    - [ ] Ability to add, remove, and modify calendar events on all integrated platforms
    - [ ] Ability to customize preferences for default calendar platform as well as default calendar.
  - [ ] Chronological Interactions with Assistant API to plan and modify your schedule throughout the day.  
    

#### Stretch Goals
- [ ] Executive Analysis
  - [ ] Ability to analyze user's habits and provide ways the user could optimize their use of time.
- [ ] Separate services into Dart isolates to improve performance