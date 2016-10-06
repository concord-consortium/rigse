require 'spec_helper'

describe UserPolicy do
  subject           { UserPolicy.new(active_user, user)    }
  let(:active_user) { nil                                  }
  let(:user)        { FactoryGirl.create(:user)            }

  context "for anonymous" do
    it { should_not permit(:limited_edit)           }
    it { should_not permit(:limited_update)         }
    it { should_not permit(:index)                  }
    it { should_not permit(:show)                   }
    it { should_not permit(:update)                 }
    it { should_not permit(:destroy)                }
    it { should_not permit(:edit)                   }
    it { should_not permit(:make_admin)             }
    it { should_not permit(:switch)                 }
    it { should_not permit(:confirm)                }
    it { should_not permit(:preferences)            }
    it { should_not permit(:reset_password)         }
    # Documenting current behavior:
    it { should_not permit(:create)                 }
    it { should_not permit(:new)                    }
  end

  context "for a normal user" do
    let(:active_user) { FactoryGirl.create(:user) }
    it { should_not permit(:limited_edit)           }
    it { should_not permit(:limited_update)         }
    it { should_not permit(:index)                  }
    it { should_not permit(:show)                   }
    it { should_not permit(:update)                 }
    it { should_not permit(:destroy)                }
    it { should_not permit(:edit)                   }
    it { should_not permit(:make_admin)             }
    it { should_not permit(:switch)                 }
    it { should_not permit(:preferences)            }
    it { should_not permit(:confirm)                }
    it { should_not permit(:reset_password)         }
    # Documenting current behavior:
    it { should permit(:create)                     }
    it { should permit(:new)                        }
  end

  context "for an admin" do
    let(:active_user) { Factory.next(:admin_user)   }
    it { should permit(:limited_edit)               }
    it { should permit(:limited_update)             }
    it { should permit(:index)                      }
    it { should permit(:show)                       }
    it { should permit(:update)                     }
    it { should permit(:destroy)                    }
    it { should permit(:create)                     }
    it { should permit(:new)                        }
    it { should permit(:edit)                       }
    it { should permit(:make_admin)                 }
    it { should permit(:switch)                     }
    it { should permit(:confirm)                    }
    it { should permit(:preferences)                }
    it { should permit(:reset_password)             }
    it { should permit(:student_page)               }
    it { should permit(:teacher_page)               }
  end

  context "for a teacher" do
    let(:clazz)       { FactoryGirl.create(:portal_clazz)   }
    let(:active_user) { FactoryGirl.create(:portal_teacher, clazzes: [clazz]).user }

    context "working with their own student" do
      let(:user)     { FactoryGirl.create(:full_portal_student, clazzes: [clazz]).user}
      it { should permit(:reset_password)             }
    end
    context "working with some other student" do
      let(:user)     { FactoryGirl.create(:full_portal_student).user}
      it { should_not permit(:reset_password)         }
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
      active_user.admin_for_projects.should include(project_a)
    end

    context "acting on a generic portal teacher" do
      let(:user) { regular_teacher.user }
      it { should permit(:limited_edit)               }
      it { should permit(:limited_update)             }
      it { should permit(:index)                      }
      it { should permit(:show)                       }
      it { should_not permit(:update)                 }
      it { should_not permit(:destroy)                }
      it { should_not permit(:edit)                   }
      it { should_not permit(:make_admin)             }
      it { should_not permit(:confirm)                }
      it { should_not permit(:preferences)            }
      it { should_not permit(:reset_password)         }
      it { should_not permit(:student_page)           }
      it { should_not permit(:teacher_page)           }
      # Documenting current behavior:
      it { should permit(:create)                     }
      it { should permit(:new)                        }
    end

    context "acting on a portal teacher in hir project cohort" do
      let(:user) { a_teacher.user }
      it { should permit(:index)                      }
      it { should permit(:show)                       }
      it { should permit(:confirm)                    }
      it { should_not permit(:preferences)            }
      it { should permit(:reset_password)             }
      it { should permit(:update)                     }
      it { should_not permit(:destroy)                }
      it { should permit(:edit)                       }
      it { should_not permit(:make_admin)             }
      it { should permit(:switch)                     }
      # Documenting current behavior:
      it { should permit(:create)                     }
      it { should permit(:new)                        }
    end

    context "acting on a portal administrator" do
      before(:all) do
        user.add_role("admin")
      end
      let(:user) { a_teacher.user }
      it { should permit(:index)                      }
      it { should_not permit(:make_admin)             }
      it { should permit(:show)                       }
      it { should_not permit(:confirm)                }
      it { should_not permit(:reset_password)         }
      it { should_not permit(:preferences)            }
      it { should_not permit(:switch)                 }
      it { should_not permit(:update)                 }
      it { should_not permit(:destroy)                }
      it { should_not permit(:edit)                   }
      # Documenting current behavior:
      it { should permit(:create)                     }
      it { should permit(:new)                        }
    end

    context "acting on a regular student" do
      let(:user) { regular_student.user }
      it { should permit(:index)                      }
      it { should_not permit(:limited_edit)           }
      it { should_not permit(:limited_update)         }
      it { should_not permit(:make_admin)             }
      it { should_not permit(:show)                   }
      it { should_not permit(:confirm)                }
      it { should_not permit(:reset_password)         }
      it { should_not permit(:preferences)            }
      it { should_not permit(:switch)                 }
      it { should_not permit(:update)                 }
      it { should_not permit(:destroy)                }
      it { should_not permit(:edit)                   }
      # Documenting current behavior:
      it { should permit(:create)                     }
      it { should permit(:new)                        }
    end

    context "acting on a student in hir project cohort" do
      let(:user) { a_student.user }
      it { should permit(:index)                      }
      it { should_not permit(:make_admin)             }
      it { should permit(:show)                       }
      it { should permit(:confirm)                    }
      it { should permit(:reset_password)             }
      it { should_not permit(:preferences)            }
      it { should permit(:switch)                     }
      it { should permit(:update)                     }
      it { should_not permit(:destroy)                }
      it { should permit(:edit)                       }
      # Documenting current behavior:
      it { should permit(:create)                     }
      it { should permit(:new)                        }
    end
  end

end