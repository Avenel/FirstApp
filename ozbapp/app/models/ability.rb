require "authentication"
class Ability
  include CanCan::Ability
  include Authentication

  def initialize(user)
    # Define abilities for the passed in user here. For example:

    user ||= User.new

    if is_allowed(user, 17)
        can :index, BuergschaftController
    end

    if is_allowed(user, 18)
        can [:new, :create, :delete], BuergschaftController
    end

    if is_allowed(user, 19)
        can [:edit, :update, :updateB], BuergschaftController
    end

    if is_allowed(user, 11)
        can [:index, :verlauf], OzbKontoController
    end

    if is_allowed(user, 13) && is_allowed(user, 15)
        can [:new, :create], OzbKontoController
    end

    if is_allowed(user, 14)
        can [:edit, :update, :delete], OzbKontoController
    end

    if is_allowed(user, 20)
        can [:editRolle], OZBPersonController
        can [:createDeleteTeilnahme, :createVeranstaltung], VeranstaltungController
    end

    if is_allowed(user, 7)
        can [:createBerechtigungRollen, :deleteBerechtigungRollen, :editRollen, :editBerechtigungenRollen, :createSonderberechtigung], SonderberechtigungController
        can [:editVeranstaltungen, :newVeranstaltung], VeranstaltungController
        can [:editBerechtigungen, :createBerechtigung, :deleteBerechtigung], :verwaltung
    end

    if is_allowed(user, 3)
        can [:newOZBPerson, :createOZBPerson, :editPersonaldaten, :updatePersonaldaten, :editKontaktdaten, :updateKontaktdaten, :editRolle, :updateRolle], :verwaltung
    end

    if is_allowed(user, 5)
        can [:deleteOZBPerson], :verwaltung
    end

    if isUserAdmin(user)
        can [:listOZBPersonen, :detailsOZBPerson], :verwaltung
    end

  end

  private
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
end
