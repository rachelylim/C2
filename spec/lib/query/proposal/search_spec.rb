describe Query::Proposal::Search do
  describe '#execute' do
    it "returns an empty list for no Proposals" do
      results = Query::Proposal::Search.new.execute('')
      expect(results).to eq([])
    end

    it "returns the Proposal when searching by ID" do
      proposal = create(:proposal)
      results = Query::Proposal::Search.new.execute(proposal.id.to_s)
      expect(results).to eq([proposal])
    end

    it "returns the Proposal when searching by public_id" do
      proposal = create(:proposal)
      proposal.update_attribute(:public_id, 'foobar') # skip callback, which would overwrite this
      results = Query::Proposal::Search.new.execute('foobar')
      expect(results).to eq([proposal])
    end

    it "can operate on an a relation" do
      proposal = create(:proposal)
      relation = Proposal.where(id: proposal.id + 1)
      results = Query::Proposal::Search.new(relation).execute(proposal.id.to_s)
      expect(results).to eq([])
    end

    it "returns an empty list for no matches" do
      create(:proposal)
      results = Query::Proposal::Search.new.execute('asgsfgsfdbsd')
      expect(results).to eq([])
    end

    context Ncr::WorkOrder do
      [:project_title, :description, :vendor].each do |attr_name|
        it "returns the Proposal when searching by the ##{attr_name}" do
          work_order = create(:ncr_work_order, attr_name => 'foo')
          results = Query::Proposal::Search.new.execute('foo')
          expect(results).to eq([work_order.proposal])
        end
      end
    end

    context Gsa18f::Procurement do
      [:product_name_and_description, :justification, :additional_info].each do |attr_name|
        it "returns the Proposal when searching by the ##{attr_name}" do
          procurement = create(:gsa18f_procurement, attr_name => 'foo')
          results = Query::Proposal::Search.new.execute('foo')
          expect(results).to eq([procurement.proposal])
        end
      end
    end

    it "returns the Proposals by rank" do
      prop1 = create(:proposal, id: 12)
      work_order = create(:ncr_work_order, project_title: "12 rolly chairs for 1600 Penn Ave")
      prop2 = work_order.proposal
      prop3 = create(:proposal, id: 1600)

      searcher = Query::Proposal::Search.new
      expect(searcher.execute('12')).to eq([prop1, prop2])
      expect(searcher.execute('1600')).to eq([prop3, prop2])
      expect(searcher.execute('12 rolly')).to eq([prop2])
    end
  end
end
