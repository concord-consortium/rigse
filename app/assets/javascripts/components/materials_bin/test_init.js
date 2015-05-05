function initITSIBin() {
  var MATERIALS = [
    {
      category: "Category a",
      children: [
        {
          category: "Category a1",
          children: [
            {
              category: "Category a11",
              children: [
                {
                  collections: [1, 2, 3]
                }
              ]
            },
            {
              category: "Category a12",
              children: [
                {
                  collections: [4, 5]
                }
              ]
            }
          ]
        },
        {
          category: "Category a2",
          children: [
            {
              category: "Category a21",
              children: [
                {
                  collections: [6]
                }
              ]
            },
            {
              category: "Category a22",
              children: [
                {
                  collections: [7, 8]
                }
              ]
            }
          ]
        }
      ]
    },
    {
      category: "Category b",
      children: [
        {
          collections: [9, 10, 11]
        }
      ]
    }
  ];

  jQuery('#primary').empty();
  React.render(MaterialsBin({materials: MATERIALS}), jQuery('#primary')[0]);
}