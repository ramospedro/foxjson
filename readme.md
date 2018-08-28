# FoxJson

An object-oriented solution to generate JSON strings using FoxPro.

## Usage

Call the function `FoxJson()` itself to create an instance of a **FoxJson** object.

    loCatJson = FoxJson()

Use the method `setProp(propName, value)` to add (or set) the desired properties.

    loCatJson.setProp('name', 'Fred')
    loCatJson.setProp('age', 2)

You can even add another **FoxJson** object as a prop.

    loKidJson = FoxJson()
    loKidJson.setProp('name', 'John')
    loKidJson.setProp('pet', loCatJson)

Getting the JSON string is just as easy a `getJson()` call.

    ? loKidJson.getJson()
    // { "name": "John", "pet": { "name": "Fred", "age": 2 } }

## Supported Values (so far)

- Number
- String
- FoxJson Object

## Testing

The **FoxJson** class is self-tested. Although it doesn't run the tests by default (for practical reasons), one can run the tests by setting *asserts on* with `SET ASSERTS ON` and  calling `FoxJson(.T.)`. If *asserts* are *on*, passing `.T.` to the constructor, makes the `init` method run the tests and output the result (or show the errors) on the screen.



