module SharedReportSpecs
  shared_examples_for "all reports" do
    context 'when building table data' do 
      it "should use default column names" do
        @html.should have_tag("tr th", /visits|views|counts/)
      end
    end
  end
end