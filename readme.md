# FoxJson

## Usage

Call the function `FoxJson()` itself to create an instance of a **FoxJson** object.

    loCatJson = FoxJson()

Use the method `addProp(propName, value)` to add the desired properties.

    loCatJson.addProp('name', 'Fred')
    loCatJson.addProp('age', 2)

You can even add a **FoxJson** object as a prop.

    loKidJson = FoxJson()
    loKidJson.addProp('name', 'John')
    loKidJson.addProp('pet', loCatJson)

Getting the JSON string is just as easy an a `getJson()` call.

    ? loKidJson.getJson()
    // { "name": "John", "pet": { "name": "Fred", "age": 2 } }

## Supported Values (So far)
- Integer
- String
- FoxJson Object

## Testing
- The **FoxJson** class is self-tested. Although it doesn't run the tests by default (for practical reasons), one can run the tests by calling `FoxJson(.T.)`. Passing `.T.` to the constructor, makes the `init` method run the tests and output the result (or throw the errors) on the screen.



