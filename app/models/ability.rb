class Ability
  include Hydra::Ability

  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #  can [:destroy], ActiveFedora::Base
    # end
    admins_can if current_user.admin?

    if current_user.read_only?
      can [:manage], Contribution
      can [:status_check], Batch
    end

    if registered_user? # rubocop:disable Style/GuardClause
      can [:create], Contribution
      #  can [:create], Batch
    end
    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
  end

  def admins_can
    can [:manage], Contribution
    can [:manage], Batch
    can [:status_check], Batch
    can [:manage], HandleLog
    can [:manage], DepositType
    can [:manage], Ead
  end
end
