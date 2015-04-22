class ProposalPolicy
  include ExceptionPolicy
  def initialize(user, record)
    super(user, record)
    @proposal = record
  end

  def author!
    check(@proposal.requester_id == @user.id,
          "You are not the requester")
  end

  def not_approved!
    check(!@proposal.approved?,
          "That proposal's already approved. New proposal?")
  end

  def approver?
    @proposal.approvals.exists?(user: @user)
  end

  def delegate?
    @proposal.delegate?(@user)
  end

  def approver!
    check(self.approver? || self.delegate?,
          "Sorry, you're not an approver on this proposal")
  end

  def observer!
    check(@proposal.observers.include?(@user),
          "Sorry, you're not an observer on this proposal")
  end

  def actionable_approvers
    @proposal.currently_awaiting_approvers
  end

  def pending_approver?
    self.actionable_approvers.include?(@user)
  end

  def pending_delegate?
    # TODO convert to SQL
    self.actionable_approvers.any? do |approver|
      approver.outgoing_delegates.exists?(assignee_id: @user.id)
    end
  end

  def pending_approval!
    check(self.pending_approver? || self.pending_delegate?,
          "A response has already been logged a response for this proposal")
  end

  def can_approve_or_reject!
    approver! && pending_approval!
  end

  def can_edit!
    author! && not_approved!
  end

  alias_method :can_update!, :can_edit!

  def can_show!
    check(@proposal.users.include?(@user),
          "You are not allowed to see this cart")
  end

  # equivalent of can_show?
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      # use subselects instead of left joins to avoid an explicit
      # duplication-removal step
      where_clause = <<-SQL
        requester_id = :user_id
        OR EXISTS (SELECT id FROM approvals
                   WHERE proposal_id = proposals.id AND user_id = :user_id)
        OR EXISTS (SELECT id FROM observations
                   WHERE proposal_id = proposals.id AND user_id = :user_id)
        SQL
      @scope.where(where_clause, user_id: @user.id)
    end
  end
end