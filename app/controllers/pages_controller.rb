class PagesController < ApplicationController

    def campaigns
        if params[:campaign_id].to_i >= 5
            csv_text = File.read('blah')
        end
    end
end
