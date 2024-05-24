const filters = {
  subjectAreas: [
    { key: 'chemistry', title: 'Chemistry', searchAreas: ['Chemistry'] },
    { key: 'earth-space', title: 'Earth & Space', searchAreas: ['Earth and Space Science'] },
    { key: 'engineering-tech', title: 'Engineering', searchAreas: ['Engineering'] },
    { key: 'life-sciences', title: 'Life Science', searchAreas: ['Biology'] },
    { key: 'mathematics', title: 'Mathematics', searchAreas: ['Mathematics'] },
    { key: 'physics', title: 'Physics', searchAreas: ['Physics'] }
  ],

  featureFilters: [
    { key: 'sequence', title: 'Sequence', searchMaterialType: 'Investigation' },
    { key: 'activity', title: 'Activity', searchMaterialType: 'Activity' },
    { key: 'model', title: 'Model', searchMaterialType: 'Interactive' },
    { key: 'browser-based', title: 'Browser-Based', searchMaterialProperty: 'Runs in browser' },
    { key: 'sensors', title: 'Sensor-Based', searchSensors: ['Force', 'Humidity (relative)', 'Light', 'Motion', 'Temperature', 'Voltage'] }
  ],

  gradeFilters: [
    { key: 'elementary-school', title: 'Elementary', grades: ['K', '1', '2', '3', '4', '5', '6'], label: 'K-6', searchGroups: ['K-2', '3-4', '5-6'] },
    { key: 'middle-school', title: 'Middle School', grades: ['7', '8'], label: '7-8', searchGroups: ['7-8'] },
    { key: 'high-school', title: 'High School', grades: ['9', '10', '11', '12'], label: '9-12', searchGroups: ['9-12'] },
    { key: 'higher-education', title: 'Higher Education', grades: ['Higher Ed'], label: 'Higher Education', searchGroups: ['Higher Ed'] }
    // {key: "informal-learning", title: "Informal Learning (TODO)", grades: [], label: "Informal Learning"},
  ]
}

export default filters
