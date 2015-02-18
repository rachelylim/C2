describe CartsHelper do
  describe '#display_status' do
    let(:current_user) { FactoryGirl.create(:user) }

    it "displays approved status" do
      cart = FactoryGirl.create(:cart, status: 'approved')
      expect(helper.display_status(cart, current_user)).to eq('Approved')
    end

    it "displays rejected status" do
      cart = FactoryGirl.create(:cart, status: 'rejected')
      expect(helper.display_status(cart, current_user)).to eq('Rejected')
    end

    context "pending" do
      context "parallel" do
        it "displays outstanding approvers" do
          cart = FactoryGirl.create(:cart_with_approvals, flow: 'parallel')
          expect(helper.display_status(cart, current_user)).to eq("<em>Waiting for review from:</em> Liono Approver1, Liono Approver2")
        end

        it "excludes approved approvals" do
          cart = FactoryGirl.create(:cart_with_approvals, flow: 'parallel')
          cart.approvals.first.approve!
          expect(helper.display_status(cart, current_user)).to eq("<em>Waiting for review from:</em> Liono Approver2")
        end

        it "references the current user" do
          cart = FactoryGirl.create(:cart_with_approvals, flow: 'parallel')
          current_user = cart.approvers.first
          expect(helper.display_status(cart, current_user)).to eq("<strong>Please review</strong>")
        end
      end

      context "linear" do
        it "displays the first approver" do
          cart = FactoryGirl.create(:cart_with_approvals, flow: 'linear')
          expect(helper.display_status(cart, current_user)).to eq("<em>Waiting for review from:</em> Liono Approver1")
        end

        it "excludes approved approvals" do
          cart = FactoryGirl.create(:cart_with_approvals, flow: 'linear')
          cart.approvals.first.approve!
          expect(helper.display_status(cart, current_user)).to eq("<em>Waiting for review from:</em> Liono Approver2")
        end

        it "references the current user" do
          cart = FactoryGirl.create(:cart_with_approvals, flow: 'linear')
          current_user = cart.approvers.first
          expect(helper.display_status(cart, current_user)).to eq("<strong>Please review</strong>")
        end
      end
    end
  end
end