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
				RETURN ALLTRIM(STR(pvValue))
			CASE VARTYPE(pvValue) == 'C'
				RETURN '"' + pvValue + '"'
			CASE VARTYPE(pvValue) == 'O'
				TRY
					lcValue = pvValue.getJson()
				CATCH
					lcValue = '"null"'
				ENDTRY
				RETURN lcValue
			OTHERWISE
				RETURN '"null"'
		ENDCASE
	ENDFUNC
	
	FUNCTION addProp(pcField, pvValue)
		loNewProp = CREATEOBJECT('Empty')
		ADDPROPERTY(loNewProp, 'name', pcField)
		ADDPROPERTY(loNewProp, 'value', pvValue)
		this.oProps.add(loNewProp)
	ENDFUNC
	
	PROCEDURE INIT(plTesting)
		this.oProps = CREATEOBJECT('Collection')
		
		IF plTesting
			this.Test_ParseValue()
			this.Test_Initial_Json_Empty()
			this.Test_AddProp_Integer()
			this.Test_AddProp_String()
			this.Test_AddProp_FoxJsonObject()
			this.Test_AddProp_UnsupportedObject()
			MESSAGEBOX('All tests passed!')
		ENDIF
	ENDPROC

	* Tests
	
	FUNCTION Test_ParseValue
		TRY
			loFoxJson = CREATEOBJECT('FoxJson')
			
			lcExpectedIntegerValue = '10'
			IF loFoxJson.parseValue(10) != lcExpectedIntegerValue
				ERROR('Parse value should parse integers')
			ENDIF
			
			lcExpectedFloatValue = '234514.564319'
			lcParsedValue = loFoxJson.parseValue(234514.564319)
			IF lcParsedValue != lcExpectedFloatValue
				ERROR('Parse values shoud parse floats: ' + lcParsedValue + ' should be equal to ' + lcExpectedFloatValue)
			ENDIF
			
			lcExpectedStringValue = '"test"'
			IF loFoxJson.parseValue("test") != lcExpectedStringValue
				ERROR('Parse value should parse strings: ' + '"test"' + ' should be equal to '+ loFoxJson.parseValue("test"))
			ENDIF
			
			loFoxJsonObj = CREATEOBJECT('FoxJson')
			loFoxJsonObj.addProp("name", "test")
			loExpectedJsonObjectValue = '{ "name": "test" }'
			IF loFoxJson.parseValue(loFoxJsonObj) != loExpectedJsonObjectValue 
				ERROR('Parse value should parse FoxJsonObjects: ' + '{ "name": "test" }' + ' should be equal to '+ loFoxJson.parseValue(loFoxJsonObj))
			ENDIF
			
			lcExpectedNullValue = '"null"'
			IF loFoxJson.parseValue(CREATEOBJECT('Empty')) != lcExpectedNullValue
				ERROR('Parse value should parse unsupported types into null values')
			ENDIF
		CATCH
			THROW
		ENDTRY
	ENDFUNC
	
	FUNCTION Test_Initial_Json_Empty
		TRY
			loFoxJson = CREATEOBJECT('FoxJson')
			lcExpectedInitialJson = '{ }'
			IF loFoxJson.getJson() != lcExpectedInitialJson
				ERROR('Initial default json should be an empty object')
			ENDIF
		CATCH
			THROW
		ENDTRY	
	ENDFUNC
	
	FUNCTION Test_AddProp_Integer
		TRY
			loFoxJson = CREATEOBJECT('FoxJson')
			
			lcExpectedJson = '{ "id": 10, "age": 20, "year": 2018 }'
			
			loFoxJson.addProp("id", 10)			
			loFoxJson.addProp("age", 20)
			loFoxJson.addProp("year", 2018)
			
			IF loFoxJson.getJson() != lcExpectedJson 
				ERROR('AddProp_Integer failed: ' + loFoxJson.getJson())
			ENDIF
			
		CATCH
			THROW
		ENDTRY	
	ENDFUNC
	
	FUNCTION Test_AddProp_String
		TRY
			loFoxJson = CREATEOBJECT('FoxJson')
			
			lcExpectedJson = '{ "name": "Robert", "city": "London", "country": "England" }'
			
			loFoxJson.addProp("name", "Robert")			
			loFoxJson.addProp("city", "London")
			loFoxJson.addProp("country", "England")
			
			IF loFoxJson.getJson() != lcExpectedJson 
				ERROR('AddProp_String failed: ' + loFoxJson.getJson())
			ENDIF
		CATCH
			THROW
		ENDTRY
	ENDFUNC

	FUNCTION Test_AddProp_FoxJsonObject
		TRY
			loFoxJsonCar = CREATEOBJECT('FoxJson')
			loFoxJsonCar.addProp("model", "camaro")
			loFoxJsonCar.addProp("year", 2017)
			
			loFoxJsonBike = CREATEOBJECT('FoxJson')
			loFoxJsonBike.addProp("model", "R6")
			loFoxJsonBike.addProp("year", 2016)
			
			lcExpectedJson = '{ "car": { "model": "camaro", "year": 2017 }, "bike": { "model": "R6", "year": 2016 } }'
			
			loFoxJson = CREATEOBJECT('FoxJson')
			loFoxJson.addProp("car", loFoxJsonCar)
			loFoxJson.addProp("bike", loFoxJsonBike)
			
			IF loFoxJson.getJson() != lcExpectedJson 
				ERROR('AddProp_FoxJsonObject failed: ' + loFoxJson.getJson())
			ENDIF
			
		CATCH
			THROW
		ENDTRY
	ENDFUNC

	FUNCTION Test_AddProp_UnsupportedObject
		TRY
			loFoxJson = CREATEOBJECT('FoxJson')
			loFoxJson.addProp("notSupported", CREATEOBJECT('Empty'))
			
			lcExpectedJson = '{ "notSupported": "null" }'
			IF loFoxJson.getJson() != lcExpectedJson 
				ERROR('AddProp_FoxJsonObject failed: ' + loFoxJson.getJson())
			ENDIF
		CATCH
			THROW
		ENDTRY
	ENDFUNC
ENDDEFINE

