class EmbeddableRefactoring < ActiveRecord::Migration
  @@all_table_pairs = [
    ['assessment_target_unifying_themes',      'ri_gse_assessment_target_unifying_themes'          ],
    ['biologica_multiple_organisms',           'embeddable_biologica_multiple_organisms'           ],
    ['biologica_breed_offsprings',             'embeddable_biologica_breed_offsprings'             ],
    ['smartgraph_range_questions',             'embeddable_smartgraph_range_questions'             ],
    ['biologica_static_organisms',             'embeddable_biologica_static_organisms'             ],
    ['biologica_chromosome_zooms',             'embeddable_biologica_chromosome_zooms'             ],
    ['biologica_meiosis_views',                'embeddable_biologica_meiosis_views'                ],
    ['multiple_choice_choices',                'embeddable_multiple_choice_choices'                ],
    ['grade_span_expectations',                'ri_gse_grade_span_expectations'                    ],
    ['expectation_indicators',                 'ri_gse_expectation_indicators'                     ],
    ['biologica_chromosomes',                  'embeddable_biologica_chromosomes'                  ],
    ['knowledge_statements',                   'ri_gse_knowledge_statements'                       ],
    ['biologica_pedigrees',                    'embeddable_biologica_pedigrees'                    ],
    ['biologica_organisms',                    'embeddable_biologica_organisms'                    ],
    ['assessment_targets',                     'ri_gse_assessment_targets'                         ],
    ['lab_book_snapshots',                     'embeddable_lab_book_snapshots'                     ],
    ['expectation_stems',                      'ri_gse_expectation_stems'                          ],
    ['vendor_interfaces',                      'probe_vendor_interfaces'                           ],
    ['multiple_choices',                       'embeddable_multiple_choices'                       ],
    ['biologica_worlds',                       'embeddable_biologica_worlds'                       ],
    ['mw_modeler_pages',                       'embeddable_mw_modeler_pages'                       ],
    ['inner_page_pages',                       'embeddable_inner_page_pages'                       ],
    ['data_collectors',                        'embeddable_data_collectors'                        ],
    ['unifying_themes',                        'ri_gse_unifying_themes'                            ],
    ['physical_units',                         'probe_physical_units'                              ],
    ['device_configs',                         'probe_device_configs'                              ],
    ['open_responses',                         'embeddable_open_responses'                         ],
    ['drawing_tools',                          'embeddable_drawing_tools'                          ],
    ['n_logo_models',                          'embeddable_n_logo_models'                          ],
    ['expectations',                           'ri_gse_expectations'                               ],
    ['data_filters',                           'probe_data_filters'                                ],
    ['calibrations',                           'probe_calibrations'                                ],
    ['inner_pages',                            'embeddable_inner_pages'                            ],
    ['probe_types',                            'probe_probe_types'                                 ],
    ['data_tables',                            'embeddable_data_tables'                            ],
    ['raw_otmls',                              'embeddable_raw_otmls'                              ],
    ['big_ideas',                              'ri_gse_big_ideas'                                  ],
    ['domains',                                'ri_gse_domains'                                    ],
    ['xhtmls',                                 'embeddable_xhtmls'                                 ]
  ]
  @@all_model_classname_pairs = [
    ['AssessmentTargetUnifyingTheme',          'RiGse::AssessmentTargetUnifyingTheme'              ],
    ['BiologicaMultipleOrganism',              'Embeddable::Biologica::MultipleOrganism'           ],
    ['BiologicaBreedOffspring',                'Embeddable::Biologica::BreedOffspring'             ],
    ['Smartgraph::RangeQuestion',              'Embeddable::Smartgraph::RangeQuestion'             ],
    ['BiologicaStaticOrganism',                'Embeddable::Biologica::StaticOrganism'             ],
    ['BiologicaChromosomeZoom',                'Embeddable::Biologica::ChromosomeZoom'             ],
    ['BiologicaMeiosisView',                   'Embeddable::Biologica::MeiosisView'                ],
    ['MultipleChoiceChoice',                   'Embeddable::MultipleChoiceChoice'                  ],
    ['GradeSpanExpectation',                   'RiGse::GradeSpanExpectation'                       ],
    ['ExpectationIndicator',                   'RiGse::ExpectationIndicator'                       ],
    ['BiologicaChromosome',                    'Embeddable::Biologica::Chromosome'                 ],
    ['KnowledgeStatement',                     'RiGse::KnowledgeStatement'                         ],
    ['BiologicaPedigree',                      'Embeddable::Biologica::Pedigree'                   ],
    ['BiologicaOrganism',                      'Embeddable::Biologica::Organism'                   ],
    ['AssessmentTarget',                       'RiGse::AssessmentTarget'                           ],
    ['LabBookSnapshot',                        'Embeddable::LabBookSnapshot'                       ],
    ['ExpectationStem',                        'RiGse::ExpectationStem'                            ],
    ['VendorInterface',                        'Probe::VendorInterface'                            ],
    ['MultipleChoice',                         'Embeddable::MultipleChoice'                        ],
    ['BiologicaWorld',                         'Embeddable::Biologica::World'                      ],
    ['MwModelerPage',                          'Embeddable::MwModelerPage'                         ],
    ['InnerPagePage',                          'Embeddable::InnerPagePage'                         ],
    ['DataCollector',                          'Embeddable::DataCollector'                         ],
    ['UnifyingTheme',                          'RiGse::UnifyingTheme'                              ],
    ['PhysicalUnit',                           'Probe::PhysicalUnit'                               ],
    ['DeviceConfig',                           'Probe::DeviceConfig'                               ],
    ['OpenResponse',                           'Embeddable::OpenResponse'                          ],
    ['DrawingTool',                            'Embeddable::DrawingTool'                           ],
    ['NLogoModel',                             'Embeddable::NLogoModel'                            ],
    ['Expectation',                            'RiGse::Expectation'                                ],
    ['DataFilter',                             'Probe::DataFilter'                                 ],
    ['Calibration',                            'Probe::Calibration'                                ],
    ['InnerPage',                              'Embeddable::InnerPage'                             ],
    ['ProbeType',                              'Probe::ProbeType'                                  ],
    ['DataTable',                              'Embeddable::DataTable'                             ],
    ['RawOtml',                                'Embeddable::RawOtml'                               ],
    ['BigIdea',                                'RiGse::BigIdea'                                    ],
    ['Domain',                                 'RiGse::Domain'                                     ],
    ['Xhtml',                                  'Embeddable::Xhtml'                                 ]
  ]

  def self.up
    @@all_table_pairs.each do |table_pair|
      rename_table table_pair[0], table_pair[1]
    end
    @@all_model_classname_pairs.each do |model_pair|
      ActiveRecord::Base.connection.update("UPDATE `page_elements` SET `embeddable_type`='#{model_pair[1]}' WHERE `embeddable_type` = '#{model_pair[0]}';")
      ActiveRecord::Base.connection.update("UPDATE `embeddable_lab_book_snapshots` SET `target_element_type`='#{model_pair[1]}' WHERE `target_element_type` = '#{model_pair[0]}';")
    end
  end

  def self.down
    @@all_table_pairs.each do |table_pair|
      rename_table table_pair[1], table_pair[0]
    end
    @@all_model_classname_pairs.each do |model_pair|
      ActiveRecord::Base.connection.update("UPDATE `page_elements` SET `embeddable_type`='#{model_pair[0]}' WHERE `embeddable_type` = '#{model_pair[1]}';")
      ActiveRecord::Base.connection.update("UPDATE `lab_book_snapshots` SET `target_element_type`='#{model_pair[0]}' WHERE `target_element_type` = '#{model_pair[1]}';")
    end
  end
end
