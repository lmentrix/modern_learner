//api: 

// http://localhost:3000/api/v1/ai/lesson-content/generate


//json input

// {
//   "topic": "TypeScript Fundamentals",
//   "language": "TypeScript",
//   "level": "intermediate",
//   "chapterTitle": "Interfaces and Shapes",
//   "lessonTitle": "Creating Interfaces",
//   "lessonType": "vocabulary",
//   "lessonDescription": "Designing user entity structures.",
//   "nativeLanguage": "English",
//   "chapterId": "dgjhieghiehgeigherig"
// }


//json output

// {
//     "data": {
//         "id": "lesson_1775288002699_esjgt6i",
//         "lessonType": "vocabulary",
//         "introduction": "Welcome to the world of Interfaces! In TypeScript, interfaces are the backbone of type safety, allowing you to define the 'shape' of objects. Mastering these is crucial for building robust, scalable applications.",
//         "vocabularyItems": [
//             {
//                 "word": "interface",
//                 "pronunciation": "/ˈɪntəfeɪs/",
//                 "translation": "A declaration that defines the structure of an object",
//                 "partOfSpeech": "noun",
//                 "exampleSentence": "interface User { id: number; name: string; }",
//                 "exampleTranslation": "Defines an object with an id and a name property",
//                 "memoryTip": "Think of an interface as a 'contract' or 'blueprint' for what shape an object must take."
//             },
//             {
//                 "word": "property",
//                 "pronunciation": "/ˈprɒpəti/",
//                 "translation": "A key-value pair within an object",
//                 "partOfSpeech": "noun",
//                 "exampleSentence": "const user: User = { id: 1, name: 'Alice' };",
//                 "exampleTranslation": "The object has properties 'id' and 'name'",
//                 "memoryTip": "Like a property of a house, it's a specific feature or attribute of the object."
//             },
//             {
//                 "word": "optional property",
//                 "pronunciation": "/ˈɒpʃənl ˈprɒpəti/",
//                 "translation": "A property that may or may not exist in an object",
//                 "partOfSpeech": "noun phrase",
//                 "exampleSentence": "interface User { email?: string; }",
//                 "exampleTranslation": "The email property is not strictly required",
//                 "memoryTip": "The question mark '?' acts like a question, asking 'Do you have this property? Maybe.'"
//             },
//             {
//                 "word": "readonly",
//                 "pronunciation": "/ˈriːdˌoʊnli/",
//                 "translation": "A property that cannot be changed after assignment",
//                 "partOfSpeech": "modifier",
//                 "exampleSentence": "interface User { readonly username: string; }",
//                 "exampleTranslation": "The username cannot be reassigned once set",
//                 "memoryTip": "Read-only means you can look at it, but don't touch/change it."
//             },
//             {
//                 "word": "type alias",
//                 "pronunciation": "/taɪp ˈeɪliəs/",
//                 "translation": "An alternative way to define shape using the 'type' keyword",
//                 "partOfSpeech": "noun phrase",
//                 "exampleSentence": "type ID = string | number;",
//                 "exampleTranslation": "Creating an alias for a union type",
//                 "memoryTip": "Think of an alias as a nickname for a specific type definition."
//             },
//             {
//                 "word": "implements",
//                 "pronunciation": "/ˈɪmplɪments/",
//                 "translation": "A keyword used to ensure a class follows a specific interface",
//                 "partOfSpeech": "verb",
//                 "exampleSentence": "class Admin implements User { ... }",
//                 "exampleTranslation": "Ensures the class follows the User interface",
//                 "memoryTip": "To implement something is to put a plan (the interface) into action."
//             },
//             {
//                 "word": "extend",
//                 "pronunciation": "/ɪkˈstend/",
//                 "translation": "Inheriting properties from one interface to another",
//                 "partOfSpeech": "verb",
//                 "exampleSentence": "interface Employee extends User { role: string; }",
//                 "exampleTranslation": "Employee includes all User properties plus role",
//                 "memoryTip": "Think of it as stretching the current interface to include more fields."
//             },
//             {
//                 "word": "shape",
//                 "pronunciation": "/ʃeɪp/",
//                 "translation": "The combination of properties and their types in an object",
//                 "partOfSpeech": "noun",
//                 "exampleSentence": "The object must match the interface's shape.",
//                 "exampleTranslation": "The data attributes must align with the definition.",
//                 "memoryTip": "Does the data fit like a puzzle piece into the interface mold?"
//             },
//             {
//                 "word": "method",
//                 "pronunciation": "/ˈmɛθəd/",
//                 "translation": "A function defined within an interface",
//                 "partOfSpeech": "noun",
//                 "exampleSentence": "interface Logger { log(msg: string): void; }",
//                 "exampleTranslation": "A logger interface containing a log function property",
//                 "memoryTip": "A method is just a function that 'lives' inside an object's definition."
//             },
//             {
//                 "word": "index signature",
//                 "pronunciation": "/ˈɪndɛks ˈsɪɡnətʃər/",
//                 "translation": "Defines property keys when names are dynamic",
//                 "partOfSpeech": "noun phrase",
//                 "exampleSentence": "interface Map { [key: string]: number; }",
//                 "exampleTranslation": "Any string key will point to a number",
//                 "memoryTip": "Like an index in a book, pointing to dynamic locations."
//             }
//         ],
//         "practiceExercises": [
//             {
//                 "type": "match",
//                 "instruction": "Match the term to its correct definition.",
//                 "items": [
//                     {
//                         "question": "readonly",
//                         "answer": "Cannot be modified after assignment."
//                     },
//                     {
//                         "question": "interface",
//                         "answer": "A blueprint for the shape of an object."
//                     },
//                     {
//                         "question": "implements",
//                         "answer": "Keyword to make a class conform to an interface."
//                     }
//                 ]
//             },
//             {
//                 "type": "fill_blank",
//                 "instruction": "Fill in the blank to make an optional property.",
//                 "items": [
//                     {
//                         "question": "interface User { name__ string; }",
//                         "answer": "?"
//                     }
//                 ]
//             },
//             {
//                 "type": "select_correct",
//                 "instruction": "Which of these is the correct way to extend an interface?",
//                 "items": [
//                     {
//                         "question": "A: interface B = A {} | B: interface B extends A {}",
//                         "answer": "B"
//                     }
//                 ]
//             }
//         ],
//         "summary": "You have learned the essentials of TypeScript Interfaces: defines shapes, handles optional fields with '?', prevents modification with 'readonly', and utilizes 'extends' and 'implements' for structural organization."
//     },
//     "statusCode": 201,
//     "timestamp": "2026-04-04T07:33:22.700Z"
// }