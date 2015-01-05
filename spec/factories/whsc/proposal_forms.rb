FactoryGirl.define do
  factory :proposal_form, class: Whsc::ProposalForm do
    amount 1000
    sequence(:approver_email) {|n| "approver#{n}@example.com" }
    sequence(:description) {|n| "Proposal #{n}" }
    expense_type 'BA80'
    association :requester, factory: :user
    sequence(:vendor) {|n| "Vendor #{n}" }
  end
end
