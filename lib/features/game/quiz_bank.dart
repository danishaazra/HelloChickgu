// Question bank helpers for review screens

List<Map<String, dynamic>> quiz1Questions() {
  return [
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  List<int> numbers = [1, 2, 3];\n"
          "  var result = numbers.map((n) => n * n).toList();\n\n"
          "  numbers.add(4);\n"
          "  print(result);\n"
          "}",
      'answers': [
        "A) [1, 4, 9, 16]",
        "B) [1, 4, 9]",
        "C) [1, 2, 3, 4]",
        "D) 2, 3, 4"
      ],
      'correctAnswer': 1,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  String name = 'Flutter';\n"
          "  print(name.length);\n"
          "}",
      'answers': [
        "A) 7",
        "B) 9",
        "C) 6",
        "D) 8"
      ],
      'correctAnswer': 0,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  int x = 5;\n"
          "  int y = x++;\n"
          "  print(y);\n"
          "}",
      'answers': [
        "A) 5",
        "B) 6",
        "C) 4",
        "D) Error"
      ],
      'correctAnswer': 0,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  List<String> fruits = ['apple', 'banana'];\n"
          "  fruits.add('orange');\n"
          "  print(fruits.length);\n"
          "}",
      'answers': [
        "A) 2",
        "B) 4",
        "C) 3",
        "D) Error"
      ],
      'correctAnswer': 1,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  int a = 10;\n"
          "  int b = 3;\n"
          "  print(a ~/ b);\n"
          "}",
      'answers': [
        "A) 3.33",
        "B) 3",
        "C) 4",
        "D) Error"
      ],
      'correctAnswer': 1,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  bool flag = true;\n"
          "  print(!flag);\n"
          "}",
      'answers': [
        "A) true",
        "B) false",
        "C) null",
        "D) Error"
      ],
      'correctAnswer': 1,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  Map<String, int> ages = {'John': 25, 'Jane': 30};\n"
          "  print(ages['John']);\n"
          "}",
      'answers': [
        "A) John",
        "B) 25",
        "C) null",
        "D) Error"
      ],
      'correctAnswer': 1,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  String text = 'Hello';\n"
          "  print(text.toUpperCase());\n"
          "}",
      'answers': [
        "A) hello",
        "B) HELLO",
        "C) Hello",
        "D) Error"
      ],
      'correctAnswer': 1,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  List<int> nums = [1, 2, 3, 4, 5];\n"
          "  print(nums.where((n) => n > 3).length);\n"
          "}",
      'answers': [
        "A) 2",
        "B) 3",
        "C) 4",
        "D) Error"
      ],
      'correctAnswer': 0,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  int? value;\n"
          "  print(value ?? 42);\n"
          "}",
      'answers': [
        "A) null",
        "B) 42",
        "C) 0",
        "D) Error"
      ],
      'correctAnswer': 1,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  Set<String> colors = {'red', 'blue', 'red'};\n"
          "  print(colors.length);\n"
          "}",
      'answers': [
        "A) 2",
        "B) 3",
        "C) 4",
        "D) Error"
      ],
      'correctAnswer': 0,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  String name = 'Dart';\n"
          "  print(name.substring(1, 3));\n"
          "}",
      'answers': [
        "A) Da",
        "B) ar",
        "C) rt",
        "D) Error"
      ],
      'correctAnswer': 1,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  List<int> numbers = [1, 2, 3];\n"
          "  numbers.removeAt(1);\n"
          "  print(numbers);\n"
          "}",
      'answers': [
        "A) [1, 3]",
        "B) [2, 3]",
        "C) [1, 2]",
        "D) Error"
      ],
      'correctAnswer': 0,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  int x = 10;\n"
          "  int y = 20;\n"
          "  print(x > y ? 'Greater' : 'Smaller');\n"
          "}",
      'answers': [
        "A) Greater",
        "B) Smaller",
        "C) Equal",
        "D) Error"
      ],
      'correctAnswer': 1,
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  List<String> items = ['a', 'b', 'c'];\n"
          "  print(items.join('-'));\n"
          "}",
      'answers': [
        "A) a-b-c",
        "B) abc",
        "C) a,b,c",
        "D) Error"
      ],
      'correctAnswer': 0,
    },
  ];
}

List<Map<String, dynamic>> quiz2Questions() {
  return [
    {
      'question': "Dart\nvoid main(){\n  print(0.1 + 0.2);\n}\n\nOutput?",
      'answers': ['0.3'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  var a = [1,2,3];\n  var b = a;\n  b.add(4);\n  print(a);\n}\n\nOutput?",
      'answers': ['[1, 2, 3, 4]','[1,2,3,4]'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  int x = 5;\n  print(++x);\n}\n\nOutput?",
      'answers': ['6'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  print('Hi' + ' Dart');\n}\n\nOutput?",
      'answers': ['Hi Dart'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  print(int.parse('12') + 8);\n}\n\nOutput?",
      'answers': ['20'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  List<int> n = [1,2,3];\n  n.add(4);\n  print(n.length);\n}\n\nOutput?",
      'answers': ['4'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  var s = {'a','b'};\n  print(s.length);\n}\n\nOutput?",
      'answers': ['2'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  var m = {'a':1,'b':2};\n  m['a'] = 5;\n  print(m);\n}\n\nOutput?",
      'answers': ['{a: 5, b: 2}','{a:5, b:2}','{a:5,b:2}'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  String t = 'abc';\n  print(t[1]);\n}\n\nOutput?",
      'answers': ['b'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  int? v;\n  print(v ?? 10);\n}\n\nOutput?",
      'answers': ['10'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  final l = [1,2,3,4];\n  print(l.first);\n}\n\nOutput?",
      'answers': ['1'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  int x = 10;\n  print(x > 5 ? 'big' : 'small');\n}\n\nOutput?",
      'answers': ['big'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  var list = [1,2,3];\n  list.removeAt(0);\n  print(list);\n}\n\nOutput?",
      'answers': ['[2, 3]','[2,3]'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  var x;\n  print(x ??= 7);\n}\n\nOutput?",
      'answers': ['7'],
      'correctAnswer': 0,
    },
    {
      'question': "Dart\nvoid main(){\n  final a = [1,2];\n  final b = a;\n  a.add(3);\n  print(b);\n}\n\nOutput?",
      'answers': ['[1, 2, 3]','[1,2,3]'],
      'correctAnswer': 0,
    },
  ];
}

List<Map<String, dynamic>> quiz3Questions() {
  return [
    {
      'question': 'In Java, which keyword is used when a method does not return any value? Choose the correct keyword to complete the statement.',
      'hint': 'It\'s the return type for methods with no result.',
      'answer': 'VOID',
    },
    {
      'question': 'In Dart, which collection stores only unique elements and does not preserve order? Select the correct term.',
      'hint': 'It is neither a List nor a Map.',
      'answer': 'SET',
    },
    {
      'question': 'In object-oriented programming (Java), which keyword is used to create a subclass that inherits from a parent class?',
      'hint': 'Appears in the class declaration to inherit.',
      'answer': 'EXTENDS',
    },
    {
      'question': 'On the web, which HTTP method is typically used to retrieve resources without modifying them?',
      'hint': 'It is safe and idempotent, often used for pages.',
      'answer': 'GET',
    },
    {
      'question': 'Which three-letter acronym stands for the standard language used to manage and query relational databases?',
      'hint': 'Think of SELECT, INSERT, and UPDATE.',
      'answer': 'SQL',
    },
    {
      'question': 'What is the common two-letter abbreviation for Artificial Intelligence?',
      'hint': 'Frequently paired with ML in tech topics.',
      'answer': 'AI',
    },
    {
      'question': 'Which three-letter keyword is commonly used to set up a counted loop in many languages?',
      'hint': 'Often seen with an index variable i.',
      'answer': 'FOR',
    },
    {
      'question': 'In Dart, the null-coalescing operator (??) returns the left operand if it is not null, otherwise the right operand. Choose a 7-letter word that describes this: it provides a fallback value.',
      'hint': 'Another word for "backup" or "substitute".',
      'answer': 'DEFAULT',
    },
    {
      'question': 'Inside a class, what do we call a function that belongs to that class?',
      'hint': 'It can access the instance\'s fields.',
      'answer': 'METHOD',
    },
    {
      'question': 'Which markup language acronym is used to structure content on the web?',
      'hint': 'Works together with CSS and JS.',
      'answer': 'HTML',
    },
    {
      'question': 'Complete the phrase: Bubble _____ is a simple sorting algorithm with O(n^2) complexity.',
      'hint': 'The missing word is the operation performed.',
      'answer': 'SORT',
    },
    {
      'question': 'Which UI toolkit is used by Dart/Flutter apps for building interfaces across platforms?',
      'hint': 'It uses widgets and hot reload.',
      'answer': 'FLUTTER',
    },
    {
      'question': 'Which structure stores key–value pairs where each key maps to a value?',
      'hint': 'In Dart, it uses curly braces with colons.',
      'answer': 'MAP',
    },
    {
      'question': 'Many programs handle tasks in parallel using multiple threads. Fill the blank: multi______.',
      'hint': 'The word describes the act of running threads.',
      'answer': 'THREAD',
    },
    {
      'question': 'What is the typical name of the entry function that many programs start from?',
      'hint': 'In C, C++, Java, and Dart, it\'s the same word.',
      'answer': 'MAIN',
    },
  ];
}

List<Map<String, dynamic>> quiz4Questions() {
  return [
    {
      'question': 'Which algorithm has O(log n) time complexity for search operations?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 1, // Binary Search
    },
    {
      'question': 'What does HTTP status code 404 mean?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 14, // Not Found
    },
    {
      'question': 'Which data structure follows LIFO principle?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 2, // Stack
    },
    {
      'question': 'What is the time complexity of quicksort in the worst case?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 8, // O(n²)
    },
    {
      'question': 'Which protocol is used for secure web communication?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 11, // HTTPS
    },
    {
      'question': 'What does SQL stand for?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 5, // Structured Query Language
    },
    {
      'question': 'Which sorting algorithm is stable?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 6, // Merge Sort
    },
    {
      'question': 'What is the maximum number of nodes in a binary tree of height h?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 13, // 2ʰ⁺¹ - 1
    },
    {
      'question': 'Which is a NoSQL database?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 3, // MongoDB
    },
    {
      'question': 'What does CSS stand for?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 9, // Cascading Style Sheets
    },
    {
      'question': 'Which is a design pattern?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 10, // Singleton
    },
    {
      'question': 'What is the time complexity of binary search?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 7, // O(log n)
    },
    {
      'question': 'Which is a version control system?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 12, // Git
    },
    {
      'question': 'What does API stand for?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 4, // Application Programming Interface
    },
    {
      'question': 'Which data structure is used in breadth-first search?',
      'answers': ['Queue', 'Binary Search', 'Stack', 'MongoDB', 'Application Programming Interface', 'Structured Query Language', 'Merge Sort', 'O(log n)', 'O(n²)', 'Cascading Style Sheets', 'Singleton', 'HTTPS', 'Git', '2ʰ⁺¹ - 1', 'Not Found'],
      'correctAnswer': 0, // Queue
    },
  ];
}


