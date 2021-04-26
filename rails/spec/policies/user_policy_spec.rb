require 'spec_helper'

describe UserPolicy do
  subject           { UserPolicy.new(active_user, user)    }
  let(:active_user) { nil                                  }
  let(:user)        { FactoryBot.create(:user)            }

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
    let(:active_user) { FactoryBot.create(:user) }
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
    let(:active_user) { FactoryBot.generate(:admin_user)    }
    let(:scope) { Pundit.policy_scope!(user, User)          }
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
    let(:clazz)       { FactoryBot.create(:portal_clazz)   }
    let(:active_user) { FactoryBot.create(:portal_teacher, clazzes: [clazz]).user }

    context "working with their own student" do
      let(:user)     { FactoryBot.create(:full_portal_student, clazzes: [clazz]).user}
      it { is_expected.to permit(:reset_password)             }
    end
    context "working with some other student" do
      let(:user)     { FactoryBot.create(:full_portal_student).user}
      it { is_expected.not_to permit(:reset_password)         }
    end
  end

  context "for a project admin" do
    let(:cohort_a)        { FactoryBot.create(:admin_cohort)                                   }
    let(:project_a)       { FactoryBot.create(:project, cohorts: [cohort_a])                   }
    let(:a_teacher)       { FactoryBot.create(:portal_teacher, cohorts: [cohort_a])            }
    let(:a_teacher_class) { FactoryBot.create(:portal_clazz, teachers: [a_teacher])            }
    let(:a_student)       { FactoryBot.create(:full_portal_student, clazzes: [a_teacher_class])}
    let(:regular_teacher) { FactoryBot.create(:portal_teacher)                                 }
    let(:regular_student) { FactoryBot.create(:full_portal_student)                            }
    let(:active_user)     { FactoryBot.create(:user)                                           }
    let(:a_researcher)    { FactoryBot.create(:user)                                           }
    let(:a_project_admin) { FactoryBot.create(:user)                                           }
    let(:scope)           { Pundit.policy_scope!(active_user, User)                                   }
    before(:each) do
      active_user.add_role_for_project('admin', project_a)
      a_project_admin.add_role_for_project('admin', project_a)
      a_researcher.add_role_for_project('researcher', project_a)
      a_teacher.reload.projects
      a_student.reload.projects
    end

    it "the active user should be a project admin" do
      expect(active_user.admin_for_projects).to include(project_a)
    end

    it "the active user should be able to view project admins and researchers in project" do
      admin_and_researcher_ids = (active_user.admin_for_project_admins + active_user.admin_for_project_researchers).uniq.map {|u| u.id}
      teachers_and_students_ids = (active_user.admin_for_project_teachers + active_user.admin_for_project_students).uniq.map {|u| u.user_id}
      user_ids = (admin_and_researcher_ids + teachers_and_students_ids).uniq
      scope.where(["(users.id IN (?)) OR (users.id IN (SELECT user_id FROM portal_teachers))", user_ids])
      teacher_user = User.where(id: a_teacher.user_id).first
      student_user = User.where(id: a_student.user_id).first
      expect(user_ids).to_not be_empty
      expect(scope.to_a).to match_array([active_user, a_project_admin, a_researcher, teacher_user, student_user])
    end

    context "acting on a researcher in hir project" do
      let(:user) { a_researcher }
      it { is_expected.to permit(:index)                      }
      it { is_expected.not_to permit(:show)                   }
      it { is_expected.not_to permit(:limited_edit)           }
      it { is_expected.not_to permit(:limited_update)         }
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

    context "acting on a project admin in hir project" do
      let(:user) { a_project_admin }
      it { is_expected.to permit(:index)                      }
      it { is_expected.not_to permit(:show)                   }
      it { is_expected.not_to permit(:limited_edit)           }
      it { is_expected.not_to permit(:limited_update)         }
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
      end
      it { is_expected.to permit(:index)                      }
      it { is_expected.not_to permit(:make_admin)             }
      it { is_expected.to permit(:show)                       }
      it { is_expected.to permit(:confirm)                    }
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


  # TODO: auto-generated
  describe '#index?' do
    it 'index?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.index?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#limited_edit?' do
    it 'limited_edit?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.limited_edit?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#limited_update?' do
    it 'limited_update?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.limited_update?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#edit?' do
    it 'edit?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.edit?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update?' do
    it 'update?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.update?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#make_admin?' do
    it 'make_admin?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.make_admin?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#show?' do
    it 'show?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.show?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#destroy?' do
    it 'destroy?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.destroy?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#teacher_page?' do
    it 'teacher_page?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.teacher_page?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#student_page?' do
    it 'student_page?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.student_page?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#switch?' do
    it 'switch?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.switch?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#confirm?' do
    it 'confirm?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.confirm?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#reset_password?' do
    xit 'reset_password?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.reset_password?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#preferences?' do
    it 'preferences?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.preferences?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#favorites?' do
    it 'favorites?' do
      user_policy = described_class.new(nil, nil)
      result = user_policy.favorites?

      expect(result).not_to be_nil
    end
  end

end
