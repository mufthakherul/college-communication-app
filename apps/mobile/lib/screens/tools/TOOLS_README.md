# Student Tools - Feature Documentation

## Overview
This directory contains 27 student productivity tools organized into 4 categories. The tools are designed to help Computer Science & Technology (CST) students with their daily academic needs.

## Tool Categories

### 🖥️ CST Tools (10 tools)
Tools specifically designed for Computer Science & Technology students.

1. **Binary Converter** (`binary_converter_screen.dart`)
   - Convert between Decimal, Binary, Hexadecimal, and Octal
   - Bitwise operations (AND, OR, XOR, NOT, Left/Right Shift)
   - Two's complement calculator (8, 16, 32-bit)
   - Quick reference table

2. **ASCII Table** (`ascii_table_screen.dart`)
   - Standard ASCII (0-127) and Extended ASCII (128-255)
   - Search functionality
   - Character descriptions and categories
   - Copy to clipboard for all values

3. **Code Snippet Manager** (`code_snippet_manager_screen.dart`)
   - Store and organize code snippets
   - Support for 13 programming languages
   - Search by title, description, or tags
   - Language filtering
   - Default snippets included

4. **IP Calculator** (`ip_calculator_screen.dart`)
   - IPv4: Network, broadcast, subnet mask, wildcard mask
   - IPv4: Host calculation, IP class, IP type
   - IPv6: Address expansion/compression
   - IPv6: Network calculation, type detection

5. **Regex Tester** (`regex_tester_screen.dart`)
   - Live pattern matching
   - Common patterns library (Email, URL, Phone, etc.)
   - Replace functionality
   - Match highlighting
   - Quick reference guide

6. **JSON Formatter** (`json_formatter_screen.dart`)
   - Format and minify JSON
   - Validate JSON syntax
   - Escape/unescape strings
   - Customizable indentation
   - XML examples

7. **Hash Generator** (`hash_generator_screen.dart`)
   - Generate MD5, SHA-1, SHA-256, SHA-512
   - Algorithm comparison table
   - Security recommendations
   - Uppercase/lowercase options

8. **Base64 Converter** (`base64_converter_screen.dart`)
   - Encode/decode Base64
   - Bidirectional conversion
   - Examples and use cases
   - Educational information

9. **Color Picker** (`color_picker_screen.dart`)
   - HEX, RGB, HSL formats
   - Interactive sliders
   - Preset color palette
   - Color information (luminance, brightness)
   - Copy in multiple formats

10. **Algorithm Complexity** (`algorithm_complexity_screen.dart`)
    - Reference for 30+ algorithms
    - Categories: Sorting, Searching, Data Structures, Graphs
    - Time complexity (Best, Average, Worst)
    - Space complexity
    - Stability information
    - Complexity guide

### 📚 Academic Tools (5 tools)

11. **Calculator** (`calculator_screen.dart`)
    - Basic arithmetic operations
    - Scientific functions
    - History tracking
    - π and e constants

12. **Dictionary** (`dictionary_screen.dart`)
    - Word definitions
    - Pronunciation guide
    - Examples and usage

13. **Periodic Table** (`periodic_table_screen.dart`)
    - Interactive periodic table
    - Element details
    - Chemical properties

14. **Formula Sheet** (`formula_sheet_screen.dart`)
    - 70+ formulas across 7 subjects
    - Categories: Math, Physics, Chemistry, Electronics, Computer Science, Networking, Digital Logic
    - Searchable and copyable
    - Detailed descriptions

15. **GPA Calculator** (`gpa_calculator_screen.dart`)
    - Calculate GPA and CGPA
    - Multiple grading systems
    - Grade tracking

### ⏰ Productivity Tools (7 tools)

16. **Attendance Tracker** (`attendance_tracker_screen.dart`)
    - Track class attendance
    - Calculate attendance percentage
    - Subject-wise tracking

17. **Exam Countdown** (`exam_countdown_screen.dart`)
    - Count down to exams
    - Multiple exam tracking
    - Notifications

18. **Assignment Tracker** (`assignment_tracker_screen.dart`)
    - Track assignments and deadlines
    - Priority levels
    - Status management

19. **Timetable** (`timetable_screen.dart`)
    - Weekly class schedule
    - Color-coded subjects
    - Edit and manage

20. **Events** (`events_screen.dart`)
    - College events calendar
    - Event details
    - Reminders

21. **Study Timer** (`study_timer_screen.dart`)
    - Pomodoro timer
    - Break reminders
    - Session tracking

22. **Quick Notes** (`notes_screen.dart`)
    - Quick note-taking
    - Search and organize
    - Markdown support

### 🛠️ Utilities (5 tools)

23. **AI Chatbot** (`ai_chat_history_screen.dart`)
    - AI-powered assistant
    - Study help
    - Chat history

24. **Expense Tracker** (`expense_tracker_screen.dart`)
    - Track expenses
    - Budget management
    - Category-wise analysis

25. **Unit Converter** (`unit_converter_screen.dart`)
    - Length, weight, temperature
    - Volume, area, time
    - Multiple unit systems

26. **World Clock** (`world_clock_screen.dart`)
    - Multiple time zones
    - Time difference calculator
    - Add custom cities

27. **Important Links** (`tools_screen.dart`)
    - Quick access to college resources
    - BTEB portal
    - Library and student portals

## Recent Improvements (v2.1)

### Enhanced Tools
- **Binary Converter**: Added bitwise operations and two's complement
- **ASCII Table**: Extended ASCII support (256 characters)
- **Code Snippet Manager**: Search and 4 more languages
- **IP Calculator**: Full IPv6 support
- **Formula Sheet**: 36 new CST-specific formulas

### New CST Tools Added
- Regex Tester
- JSON Formatter
- Hash Generator
- Base64 Converter
- Color Picker
- Algorithm Complexity

## Architecture

### File Structure
```
lib/screens/tools/
├── tools_screen.dart          # Main tools screen with category tabs
├── [tool_name]_screen.dart    # Individual tool screens
└── TOOLS_README.md            # This file
```

### Main Screen (`tools_screen.dart`)
- Implements `TabController` for 5 categories
- Grid layout for tool cards
- Category-based filtering
- Navigation to individual tools

### Tool Screen Pattern
Each tool follows this pattern:
1. StatefulWidget with local state management
2. Input controls (TextFields, Sliders, etc.)
3. Processing logic
4. Result display
5. Copy to clipboard functionality
6. Help/info sections

## Dependencies
- `flutter/material.dart` - UI framework
- `flutter/services.dart` - Clipboard and input formatting
- `shared_preferences` - Local storage (for Code Snippets)
- `crypto` - Cryptographic hashing (for Hash Generator)

## Adding New Tools

To add a new tool:

1. Create a new file: `lib/screens/tools/your_tool_screen.dart`
2. Implement the tool screen widget
3. Import in `tools_screen.dart`
4. Add to appropriate category in `_buildAllToolsGrid()`
5. Add to category-specific grid method
6. Update this README

Example:
```dart
import 'package:campus_mesh/screens/tools/your_tool_screen.dart';

_buildToolCard(
  context,
  'Your Tool',
  Icons.your_icon,
  Colors.yourColor,
  const YourToolScreen(),
  'CST', // or 'Academic', 'Productivity', 'Utilities'
),
```

## Best Practices

### UI/UX
- Use Cards for sections
- Provide copy-to-clipboard for results
- Include help/info sections
- Show loading states
- Handle errors gracefully
- Use appropriate icons and colors

### Code
- Follow Flutter naming conventions
- Dispose controllers in `dispose()`
- Use const constructors where possible
- Add comments for complex logic
- Handle edge cases
- Validate user input

### Performance
- Use ListView.builder for long lists
- Implement lazy loading where needed
- Dispose resources properly
- Avoid unnecessary rebuilds

## Testing
To test tools:
1. Build the app: `flutter build apk`
2. Run on device: `flutter run`
3. Navigate to Tools section
4. Test each category
5. Verify functionality

## Contributing
When contributing new tools or improvements:
1. Follow the existing patterns
2. Update this README
3. Test thoroughly
4. Document new features
5. Handle errors gracefully

## License
Part of the RPI Communication App - Rangpur Polytechnic Institute
Developed by Mufthakherul

---
Last Updated: 2025-11-04
Version: 2.1
