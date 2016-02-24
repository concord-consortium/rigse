require 'spec_helper'

describe UserPolicy do
  subject           { UserPolicy.new(active_user, user)    }
  let(:active_user) { Factory.next(:anonymous_user)        }
  let(:user)        { FactoryGirl.create(:user)            }

  context "for anonymous" do
    it { should_not permit(:edit_by_project_admin)  }
    it { should_not permit(:update_by_project_admin)}
    it { should_not permit(:index)                  }
    it { should_not permit(:show)                   }
    it { should_not permit(:update)                 }
    it { should_not permit(:edit)                   }
    it { should_not permit(:switch)                 }
    it { should_not permit(:confirm)                }
    it { should_not permit(:reset_password)         }
    it { should permit(:create)                     }
    it { should permit(:new)                        }
  end

  context "for a normal user" do
    let(:active_user) { FactoryGirl.create(:user) }
    it { should_not permit(:edit_by_project_admin)  }
    it { should_not permit(:update_by_project_admin)}
    it { should_not permit(:index)                  }
    it { should_not permit(:show)                   }
    it { should_not permit(:update)                 }
    it { should_not permit(:edit)                   }
    it { should_not permit(:switch)                 }
    it { should_not permit(:confirm)                }
    it { should_not permit(:reset_password)         }
    # Documenting current behavior:
    it { should permit(:create)                     }
    it { should permit(:new)                        }
  end

  context "for an admin" do
    let(:active_user) { Factory.next(:admin_user)   }
    it { should permit(:index)                      }
    it { should permit(:show)                       }
    it { should permit(:update)                     }
    it { should permit(:create)                     }
    it { should permit(:new)                        }
    it { should permit(:edit)                       }
    it { should permit(:switch)                     }
    it { should permit(:confirm)                    }
    it { should permit(:reset_password)             }
  end

  context "for a project admin" do
    let(:a_teacher)       { FactoryGirl.create(:portal_teacher, cohorts:[cohort_a]) }
    let(:regular_teacher) { FactoryGirl.create(:portal_teacher)                     }
    let(:project_a)       { FactoryGirl.create(:project, cohorts: [cohort_a])       }
    let(:active_user)     { Factory.create(:user, admin_for_projects: [project_a])  }
    let(:cohort_a)        { FactoryGirl.create(:admin_cohort)                       }
    before(:each) do
      active_user.add_role_for_project('admin', project_a)
    end

    it "the active user should be a project admin" do
      active_user.admin_for_projects.should include(project_a)
    end

    context "a generic portal teacher" do
      let(:user) { regular_teacher.user }
      it { should permit(:index)                      }
      it { should_not permit(:show)                   }
      it { should_not permit(:update)                 }
      it { should_not permit(:edit)                   }
      it { should_not permit(:confirm)                }
      it { should_not permit(:reset_password)         }
      # Documenting current behavior:
      it { should permit(:create)                     }
      it { should permit(:new)                        }
    end

    context "for a user in hir project cohort" do
      let(:user) { a_teacher.user }
      it { should permit(:index)                      }
      it { should permit(:show)                       }
      it { should permit(:confirm)                    }
      it { should permit(:reset_password)             }
      it { should permit(:switch)                     }
      it { should permit(:update)                     }
      it { should permit(:edit)                       }
      # Documenting current behavior:
      it { should permit(:create)                     }
      it { should permit(:new)                        }
    end

  end

end