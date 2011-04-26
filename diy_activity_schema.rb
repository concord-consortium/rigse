  create_table "itsidiy_activities", :force => true do |t|
    t.text    "introduction"
    t.text    "standards"
    t.text    "career_stem"  
    t.text    "materials"
    t.text    "safety"
    t.text    "proced"
    t.text    "predict"
    t.text    "collectdata"
    t.text    "collectdata2"
    t.text    "collectdata3"
    t.text    "analysis"
    t.text    "conclusion"
    t.text    "career_stem2"
    t.text    "further"
    t.boolean "textile" 
    
    t.integer "probe_type_id"                 <-- (a)
    t.integer "model_id"                      <-- (a)
    
    t.boolean "introduction_text_response"
    t.boolean "introduction_drawing_response"  
    
    t.boolean "proced_text_response"
    t.boolean "proced_drawing_response"

    t.boolean "prediction_text_response"
    t.boolean "prediction_graph_response"
    t.boolean "prediction_drawing_response"
    
    t.boolean "collectdata_probe_active"
    t.boolean "collectdata_model_active"
    t.boolean "collectdata_text_response"
    t.boolean "collectdata_probe_multi"
    t.boolean "collectdata_drawing_response"
    t.boolean "collectdata_graph_response"
    t.boolean "collectdata1_calibration_active"  <-- (a2)
    t.integer "collectdata1_calibration_id"      <-- (a2)
    
    t.boolean "collectdata2_text_response"
    t.boolean "collectdata2_probe_active"
    t.boolean "collectdata2_model_active"
    t.integer "collectdata2_probetype_id"
    t.integer "collectdata2_model_id"
    t.boolean "collectdata2_probe_multi"
    t.boolean "collectdata2_drawing_response"
    t.boolean "collectdata2_calibration_active"
    t.integer "collectdata2_calibration_id"
    
    t.boolean "collectdata3_text_response"
    t.boolean "collectdata3_probe_active"
    t.boolean "collectdata3_model_active"
    t.boolean "collectdata3_probe_multi"
    t.integer "collectdata3_probetype_id"
    t.integer "collectdata3_model_id"
    t.boolean "collectdata3_drawing_response"
    t.boolean "collectdata3_calibration_active"
    t.integer "collectdata3_calibration_id"
    
    t.boolean "further_model_active"
    t.integer "further_model_id"
    t.boolean "further_drawing_response"
    t.boolean "further_text_response"
    t.boolean "further_probe_active"
    t.integer "further_probetype_id"
    t.boolean "further_probe_multi"
    t.boolean "furtherprobe_calibration_active"   <-- (b)
    t.integer "furtherprobe_calibration_id"       <-- (b)
    
    t.boolean "analysis_drawing_response"
    t.boolean "analysis_text_response"
   
    t.boolean "conclusion_text_response"
  
    t.boolean "career_stem_text_response"
    t.boolean "career_stem2_text_response"
  end

