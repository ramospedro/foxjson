LPARAMETERS plTesting

RETURN CREATEOBJECT('FoxJson', plTesting)

DEFINE CLASS FoxJson as Custom
	
	HIDDEN oProps

	FUNCTION getJson()
		lcJson = '{'
		FOR EACH oProp IN this.oProps
			lcJson = lcJson + ' "' + oProp.name + '": ' + this.parseValue(oProp.value) + ','
		ENDFOR
		lcJson = IIF(LEN(lcJson) > 1, LEFT(lcJson, LEN(lcJson) - 1), lcJson)
		lcJson = lcJson + ' }'
		RETURN lcJson
	ENDFUNC
	
	FUNCTION parseValue(pvValue)
		DO CASE
			CASE VARTYPE(pvValue) == 'N'
				lcNumber = STR(pvValue, 20, 6)
				lnPoint = AT('.', lcNumber)
				lcLeftSide = ALLTRIM(LEFT(lcNumber, lnPoint - 1))
				lcRightSide = ALLTRIM(SUBSTR(lcNumber, lnPoint), 1, ' ', '0')
				lcParsedNumber = ALLTRIM(lcLeftSide + lcRightSide, 1, '.')
				RETURN lcParsedNumber
			CASE VARTYPE(pvValue) == 'C'
				RETURN '"' + pvValue + '"'
			CASE VARTYPE(pvValue) == 'O'
				TRY
					lcClass = LOWER(pvValue.class)
				CATCH
					lcClass = ''
				ENDTRY
				
				DO CASE
					CASE lcClass == 'collection'
						RETURN '[]'
					CASE lcClass == 'foxjson'
						RETURN pvValue.getJson()
					OTHERWISE
						RETURN '"null"'
					ENDCASE
			OTHERWISE
				RETURN '"null"'
		ENDCASE
	ENDFUNC
	
	FUNCTION setProp(pcField, pvValue)
		llPropExists = this.oProps.GetKey(pcField) > 0
		IF llPropExists
			this.oProps.Remove(pcField)
		ENDIF
		loNewProp = CREATEOBJECT('Empty')
		ADDPROPERTY(loNewProp, 'name', pcField)
		ADDPROPERTY(loNewProp, 'value', pvValue)
		this.oProps.add(loNewProp, pcField)
	ENDFUNC
	
	PROCEDURE INIT(plTesting)
		this.oProps = CREATEOBJECT('Collection')
		
		IF plTesting AND SET("Asserts") == 'ON'
			this.Test_ParseValue()
			this.Test_ParseValue_Collection()
			this.Test_Initial_Json_Empty()
			this.Test_SetProp_Number()
			this.Test_SetProp_String()
			this.Test_SetProp_FoxJsonObject()
			this.Test_SetProp_UnsupportedObject()
			this.Test_SetProp_No_Duplicates()
			
			MESSAGEBOX('All tests passed!')
		ENDIF
	ENDPROC

	* Tests
	
	FUNCTION Test_ParseValue
		loFoxJson = CREATEOBJECT('FoxJson')
			
		lcExpectedIntegerValue = '102000'
		lcParsedValue = loFoxJson.parseValue(102000)
		ASSERT lcParsedValue == lcExpectedIntegerValue ;
			MESSAGE 'Parse value should parse integers: ' + lcParsedValue + ' should be equal to ' + lcExpectedIntegerValue
			
			
		lcExpectedFloatValue = '234514.564319'
		lcParsedValue = loFoxJson.parseValue(234514.564319)
		ASSERT lcParsedValue == lcExpectedFloatValue ;
			MESSAGE 'Parse values shoud parse floats: ' + lcParsedValue + ' should be equal to ' + lcExpectedFloatValue
			
		lcExpectedStringValue = '"test"'
		ASSERT loFoxJson.parseValue("test") == lcExpectedStringValue ;
			MESSAGE 'Parse value should parse strings: ' + '"test"' + ' should be equal to '+ loFoxJson.parseValue("test")
			
		loFoxJsonObj = CREATEOBJECT('FoxJson')
		loFoxJsonObj.setProp("name", "test")
		loExpectedJsonObjectValue = '{ "name": "test" }'
		ASSERT loFoxJson.parseValue(loFoxJsonObj) == loExpectedJsonObjectValue ;
			MESSAGE 'Parse value should parse FoxJsonObjects: ' + loFoxJson.parseValue(loFoxJsonObj) + ' should be equal to '+ '{ "name": "test" }'
			
		lcExpectedNullValue = '"null"'
		ASSERT loFoxJson.parseValue(CREATEOBJECT('Empty')) == lcExpectedNullValue ;
			MESSAGE 'Parse value should parse unsupported types into null values'
	ENDFUNC
	
	FUNCTION Test_ParseValue_Collection
		loFoxJson = CREATEOBJECT('FoxJson')
		
		loEmpty = CREATEOBJECT('Collection')
		lcExpectedEmptyArrayValue = '[]'
		lcEmptyParsedArray = loFoxJson.parseValue(loEmpty)
		ASSERT lcEmptyParsedArray == lcExpectedEmptyArrayValue ;
			MESSAGE 'Test_ParseValue_Collection with empty collection falied: ' + lcEmptyParsedArray + ' should be equal to ' + lcExpectedEmptyArrayValue
			
		loCol = CREATEOBJECT('Collection')
		loCol.add(10)
		loCol.add('A')
		loJsonPerson = FoxJson()
		loJsonPerson.setProp('name', 'John')
		loJson = FoxJson()
		loJson.setProp('id', 12345)
		loJson.setProp('person', loJsonPerson)
		loCol.add(loJson)
		lcExpectedArrayValue = '[10, "A", { "person": { "id": 12345, "name": "John" } }]'
		lcParsedArray = loFoxJson.parseValue(loCol)
		ASSERT lcParsedArray == lcExpectedArrayValue ;
			MESSAGE 'Test_ParseValue_Collection failed: ' + lcParsedArray + ' should be equal to ' + lcExpectedArrayValue
	ENDFUNC
	
	FUNCTION Test_Initial_Json_Empty
		loFoxJson = CREATEOBJECT('FoxJson')
		lcExpectedInitialJson = '{ }'
		ASSERT loFoxJson.getJson() == lcExpectedInitialJson ;
			MESSAGE 'Initial default json should be an empty object'
	ENDFUNC
	
	FUNCTION Test_SetProp_Number
		loFoxJson = CREATEOBJECT('FoxJson')
		
		lcExpectedJson = '{ "id": 10, "age": 20, "year": 2018, "twoRelevantDecimals": 20.45, "noRelevantDecimals": 20 }'
		loFoxJson.setProp("id", 10)			
		loFoxJson.setProp("age", 20)
		loFoxJson.setProp("year", 2018)
		loFoxJson.setProp("twoRelevantDecimals", 20.450)
		loFoxJson.setProp("noRelevantDecimals", 20.00)
		ASSERT loFoxJson.getJson() == lcExpectedJson ;
			MESSAGE 'SetProp_Number failed. Numbers should be added including only relevant decimals: ' + loFoxJson.getJson()
	ENDFUNC
	
	FUNCTION Test_SetProp_String
		loFoxJson = CREATEOBJECT('FoxJson')
			
		lcExpectedJson = '{ "name": "Robert", "city": "London", "country": "England" }'
			
		loFoxJson.setProp("name", "Robert")			
		loFoxJson.setProp("city", "London")
		loFoxJson.setProp("country", "England")
			
		ASSERT loFoxJson.getJson() == lcExpectedJson ;
			MESSAGE 'SetProp_String failed: ' + loFoxJson.getJson()
	ENDFUNC

	FUNCTION Test_SetProp_FoxJsonObject
		loFoxJsonCar = CREATEOBJECT('FoxJson')
		loFoxJsonCar.setProp("model", "camaro")
		loFoxJsonCar.setProp("year", 2017)
			
		loFoxJsonBike = CREATEOBJECT('FoxJson')
		loFoxJsonBike.setProp("model", "R6")
		loFoxJsonBike.setProp("year", 2016)
			
		lcExpectedJson = '{ "car": { "model": "camaro", "year": 2017 }, "bike": { "model": "R6", "year": 2016 } }'
			
		loFoxJson = CREATEOBJECT('FoxJson')
		loFoxJson.setProp("car", loFoxJsonCar)
		loFoxJson.setProp("bike", loFoxJsonBike)
			
		ASSERT loFoxJson.getJson() == lcExpectedJson ;
			MESSAGE 'SetProp_FoxJsonObject failed: ' + loFoxJson.getJson()
	ENDFUNC

	FUNCTION Test_SetProp_UnsupportedObject
		loFoxJson = CREATEOBJECT('FoxJson')
		loFoxJson.setProp("notSupported", CREATEOBJECT('Empty'))
			
		lcExpectedJson = '{ "notSupported": "null" }'
		ASSERT loFoxJson.getJson() == lcExpectedJson ;
			MESSAGE 'SetProp_FoxJsonObject failed: ' + loFoxJson.getJson()
	ENDFUNC

	FUNCTION Test_SetProp_No_Duplicates
		loFoxJson = CREATEOBJECT('FoxJson')
		loFoxJson.setProp('propA', 1)
		loFoxJson.setProp('propB', 'a')
		loFoxJson.setProp('propA', 'A')
		loFoxJson.setProp('propB', 2)
			
		lcExpectedJson = '{ "propA": "A", "propB": 2 }'
			
		ASSERT loFoxJson.getJson() == lcExpectedJson ;
			MESSAGE 'Test_SetProp_No_Duplicates failed: ' + loFoxJson.getJson() + ' should be equals to ' + lcExpectedJson
	ENDFUNC

ENDDEFINE

