

Part of the portal API defined in `_api_paths.html.haml` in the RIGSE project defines
`Portal.API_V1.getNavigation()`.  This returns a nested JSON structure of links and sections.

You can check out the example html in `./src/portals/learn-stem.concord.org/testing/navigation.html` which includes static JSON describing the navigation structure.

Here is another example navigation JSON might look like:

```JSON

    {
      "name": "Mad Franky",
      "help": {
        "label": "help",
        "url": "/help",
        "id": "/help",
        "type": "LINK",
        "popOut": true
      },
      "greeting": "Hello",
      "selected_section": "__ROOT__",
      "request_path": "/",
      "links": [
        {
          "type": "SECTION",
          "sort": 5,
          "id": "/classes",
          "label": "Classes",
          "children": [
            {
              "type": "SECTION",
              "sort": 1,
              "id": "/classes/2",
              "label": "Noahs Class",
              "children": [
                {
                  "type": "LINK",
                  "sort": 0,
                  "id": "/classes/2/roster",
                  "label": "Class Roster",
                  "url": "/classes/2/roster"
                },
                {
                  "type": "LINK",
                  "sort": 1,
                  "id": "/classes/2/assign",
                  "label": "Assign Material",
                  "url": "/classes/2/edit"
                }
              ]
            }
          ]
        },
        {
          "type": "SECTION",
          "sort": 5,
          "id": "/resources",
          "label": "Resources",
          "children": [
            {
              "type": "LINK",
              "sort": 1,
              "id": "/resources/schoology",
              "label": "schoology",
              "url": "http://scologoy.com"
            }
          ]
        },
        {
          "type": "LINK",
          "sort": 5,
          "id": "google",
          "label": "google",
          "url": "http://google.com"
        }
      ]
    }

```


The Schema for this structure is listed below:

```JSON

    {
      "definitions": {
        "item": {
          "type": "object",
          "properties": {
            "id":       { "type": "string"  },
            "label":    { "type": "string"  },
            "url":      { "type": "string"  },
            "type":     { "type": "string"  },
            "onClick":  { "type": "string"  },
            "popOut":   { "type": "boolean" },
            "sort":     { "type": "number"  },
            "selected": { "type": "boolean" },
            "iconName": { "type": "string"  },
            "small":    { "type": "boolean" },
            "divider":  { "type": "boolean" },
            "children": {
              "type": "array",
              "items": {"$ref": "#/definitions/item"}
            }
          },
          "required": [ "id", "label", "type"]
        }
      },
      "type": "object",
      "required": [
        "name",
        "greeting",
        "help"
      ],
      "properties": {
        "greeting": {"type": "string"},
        "name" : { "type" : "string" },
        "help" : { "$ref": "#/definitions/item" },
        "links": {
          "type": "array",
          "items": { "$ref": "#/definitions/item"}
        }
      }
    }

```