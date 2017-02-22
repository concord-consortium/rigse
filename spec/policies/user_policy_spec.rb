require 'spec_helper'

describe UserPolicy do
  subject           { UserPolicy.new(active_user, user)    }
  let(:active_user) { nil                                  }
  let(:user)        { FactoryGirl.create(:user)            }

  context "for anonymous" do
    it { is_expected.not_to permit(:limited_edit)           }
    it { is_expected.not_to permit(:limited_update)         }
    it { is_expected.not_to permit(:index)                  }
    it { is_expected.not_to permit(:show)                   }
    it { is_expected.not_to permit(:update)                 }
    it { is_expected.not_to permit(:destroy)                }
    it { is_expected.not_to permit(:edit)                   }
    it { is_expected.not_to permit(:make_admin)             }
    it { is_expected.not_to permit(:switch)                 }
    it { is_expected.not_to permit(:confirm)                }
    it { is_expected.not_to permit(:preferences)            }
    it { is_expected.not_to permit(:reset_password)         }
    # Documenting current behavior:
    it { is_expected.not_to permit(:create)                 }
    it { is_expected.not_to permit(:new)                    }
  end

  context "for a normal user" do
    let(:active_user) { FactoryGirl.create(:user) }
    it { is_expected.not_to permit(:limited_edit)           }
    it { is_expected.not_to permit(:limited_update)         }
    it { is_expected.not_to permit(:index)                  }
    it { is_expected.not_to permit(:show)                   }
    it { is_expected.not_to permit(:update)                 }
    it { is_expected.not_to permit(:destroy)                }
    it { is_expected.not_to permit(:edit)                   }
    it { is_expected.not_to permit(:make_admin)             }
    it { is_expected.not_to permit(:switch)                 }
    it { is_expected.not_to permit(:preferences)            }
    it { is_expected.not_to permit(:confirm)                }
    it { is_expected.not_to permit(:reset_password)         }
    # Documenting current behavior:
    it { is_expected.to permit(:create)                     }
    it { is_expected.to permit(:new)                        }
  end

  context "for an admin" do
    let(:active_user) { Factory.next(:admin_user)   }
    it { is_expected.to permit(:limited_edit)               }
    it { is_expected.to permit(:limited_update)             }
    it { is_expected.to permit(:index)                      }
    it { is_expected.to permit(:show)                       }
    it { is_expected.to permit(:update)                     }
    it { is_expected.to permit(:destroy)                    }
    it { is_expected.to permit(:create)                     }
    it { is_expected.to permit(:new)                        }
    it { is_expected.to permit(:edit)                       }
    it { is_expected.to permit(:make_admin)                 }
    it { is_expected.to permit(:switch)                     }
    it { is_expected.to permit(:confirm)                    }
    it { is_expected.to permit(:preferences)                }
    it { is_expected.to permit(:reset_password)             }
    it { is_expected.to permit(:student_page)               }
    it { is_expected.to permit(:teacher_page)               }
  end

  context "for a teacher" do
    let(:clazz)       { FactoryGirl.create(:portal_clazz)   }
    let(:active_user) { FactoryGirl.create(:portal_teacher, clazzes: [clazz]).user }

    context "working with their own student" do
      let(:user)     { FactoryGirl.create(:full_portal_student, clazzes: [clazz]).user}
      it { is_expected.to permit(:reset_password)             }
    end
    context "working with some other student" do
      let(:user)     { FactoryGirl.create(:full_portal_student).user}
      it { is_expected.not_to permit(:reset_password)         }
    end
  end

  context "for a project admin" do
    let(:a_teacher)       { FactoryGirl.create(:portal_teacher, cohorts: [cohort_a])            }
    let(:regular_teacher) { FactoryGirl.create(:portal_teacher)                                 }
    let(:a_student)       { FactoryGirl.create(:full_portal_student, clazzes: [a_teacher_class])}
    let(:regular_student) { FactoryGirl.create(:full_portal_student)                            }
    let(:project_a)       { FactoryGirl.create(:project, cohorts: [cohort_a])                   }
    let(:active_user)     { FactoryGirl.create(:user, admin_for_projects: [project_a])              }
    let(:cohort_a)        { FactoryGirl.create(:admin_cohort)                                   }
    let(:a_teacher_class) { FactoryGirl.create(:portal_clazz, teachers: [a_teacher])            }
    before(:each) do
      active_user.add_role_for_project('admin', project_a)
    end

    it "the active user should be a project admin" do
      expect(active_user.admin_for_projects).to include(project_a)
    end

    context "acting on a generic portal teacher" do
      let(:user) { regular_teacher.user }
      it { is_expected.to permit(:limited_edit)               }
      it { is_expected.to permit(:limited_update)             }
      it { is_expected.to permit(:index)                      }
      it { is_expected.to permit(:show)                       }
      it { is_expected.not_to permit(:update)                 }
      it { is_expected.not_to permit(:destroy)                }
      it { is_expected.not_to permit(:edit)                   }
      it { is_expected.not_to permit(:make_admin)             }
      it { is_expected.not_to permit(:confirm)                }
      it { is_expected.not_to permit(:preferences)            }
      it { is_expected.not_to permit(:reset_password)         }
      it { is_expected.not_to permit(:student_page)           }
      it { is_expected.not_to permit(:teacher_page)           }
      # Documenting current behavior:
      it { is_expected.to permit(:create)                     }
      it { is_expected.to permit(:new)                        }
    end

    context "acting on a portal teacher in hir project cohort" do
      let(:user) { a_teacher.user }
      it { is_expected.to permit(:index)                      }
      it { is_expected.to permit(:show)                       }
      it { is_expected.to permit(:confirm)                    }
      it { is_expected.not_to permit(:preferences)            }
      it { is_expected.to permit(:reset_password)             }
      it { is_expected.to permit(:update)                     }
      it { is_expected.not_to permit(:destroy)                }
      it { is_expected.to permit(:edit)                       }
      it { is_expected.not_to permit(:make_admin)             }
      it { is_expected.to permit(:switch)                     }
      # Documenting current behavior:
      it { is_expected.to permit(:create)                     }
      it { is_expected.to permit(:new)                        }
    end

    context "acting on a portal administrator" do
      let(:user) { a_teacher.user }
      before(:each) do
        user.add_role("admin")
        a_teacher.cohorts = []
        a_teacher.save
      end
      it { is_expected.to permit(:index)                      }
      it { is_expected.not_to permit(:make_admin)             }
      it { is_expected.to permit(:show)                       }
      it { is_expected.not_to permit(:confirm)                }
      it { is_expected.not_to permit(:reset_password)         }
      it { is_expected.not_to permit(:preferences)            }
      it { is_expected.not_to permit(:switch)                 }
      it { is_expected.not_to permit(:update)                 }
      it { is_expected.not_to permit(:destroy)                }
      it { is_expected.not_to permit(:edit)                   }
      # Documenting current behavior:
      it { is_expected.to permit(:create)                     }
      it { is_expected.to permit(:new)                        }
    end

    context "acting on a regular student" do
      let(:user) { regular_student.user }
      it { is_expected.to permit(:index)                      }
      it { is_expected.not_to permit(:limited_edit)           }
      it { is_expected.not_to permit(:limited_update)         }
      it { is_expected.not_to permit(:make_admin)             }
      it { is_expected.not_to permit(:show)                   }
      it { is_expected.not_to permit(:confirm)                }
      it { is_expected.not_to permit(:reset_password)         }
      it { is_expected.not_to permit(:preferences)            }
      it { is_expected.not_to permit(:switch)                 }
      it { is_expected.not_to permit(:update)                 }
      it { is_expected.not_to permit(:destroy)                }
      it { is_expected.not_to permit(:edit)                   }
      # Documenting current behavior:
      it { is_expected.to permit(:create)                     }
      it { is_expected.to permit(:new)                        }
    end

    context "acting on a student in hir project cohort" do
      let(:user) { a_student.user }
      it { is_expected.to permit(:index)                      }
      it { is_expected.not_to permit(:make_admin)             }
      it { is_expected.to permit(:show)                       }
      it { is_expected.to permit(:confirm)                    }
      it { is_expected.to permit(:reset_password)             }
      it { is_expected.not_to permit(:preferences)            }
      it { is_expected.to permit(:switch)                     }
      it { is_expected.to permit(:update)                     }
      it { is_expected.not_to permit(:destroy)                }
      it { is_expected.to permit(:edit)                       }
      # Documenting current behavior:
      it { is_expected.to permit(:create)                     }
      it { is_expected.to permit(:new)                        }
    end
  end

end