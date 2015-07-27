class PagesController < ApplicationController

    def campaigns
        if params[:campaign_id].to_i >= 5
        end
    end

    def get_banner(campaign_id)
    
        $debug_str = ""  

        #Load csv files
        clicks_data = load_clicks_csv_file
        conversions_data = load_converions_csv_file

        #get a subet for only current campaign id
        clicks_data_subset = get_clicks_by_campaign_id(clicks_data, campaign_id)

        #get banners with revenue 
        banner_revenue = get_banners_with_revenue(clicks_data_subset, conversions_data)

        #calculate and calculate clicks
        banner_clicks = get_banners_clicks(clicks_data_subset)
        
        #Get the top10 banners according to revenue 
        banner_top10 = get_banner_top10(banner_revenue, banner_clicks)

        #Get banner to display
        banner_to_display = get_banner_to_display(banner_top10)
        
        $debug_str += "\nbanner to display: " + banner_to_display.to_s 
        $debug_str += "\nsession[:ads_served] = " + session[:ads_served].to_s + " size=" + session[:ads_served].size.to_s + "\n"

        $debug_str += "\n --- top10 --- \n" #+ banner_top10.to_s
        for banner in banner_top10
            $debug_str += banner.to_s + "\n"
        end
        $debug_str += "-------------------------------------------\n"   

        return $debug_str
        return banner_to_display.to_s
    end

    def load_converions_csv_file
        csv_conversions= CSV.read("app/assets/csv/conversions_1.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all} )
        conversions_data = csv_conversions.map { |d| d.to_hash}

        return conversions_data
    end


    def load_clicks_csv_file
        csv_clicks= CSV.read("app/assets/csv/clicks_1.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all} )
        clicks_data = csv_clicks.map { |d| d.to_hash }
        
        return clicks_data
    end

    def get_clicks_by_campaign_id(clicks_data, campaign_id)
        count = 0;
        clicks_data_subset = Array.new
        for click in clicks_data
            if click[:campaign_id].to_i == campaign_id.to_i
                clicks_data_subset[count] = click.to_h
                count += 1
            end
        end
        return clicks_data_subset
    end

    def get_banners_with_revenue(clicks_data_subset, conversions_data)
        
        #banners with conversions, note that the clicks have to be sorted according to banner_id for this block
        #since it sums up the revenues for each banner and checks if last_banner_id == banner_id
        
        clicks_data_subset.sort_by! {|v| v[:banner_id]}
        #$debug_str += "\n\n " + clicks_data_subset.to_s + "\n\n"

        #calculate banner revenue and click array
        banner_revenue = Array.new
        count = 0
        last_banner_id = -1
        for click in clicks_data_subset
            for conversion in conversions_data
                if (click[:click_id].to_i == conversion[:click_id].to_i)
                    #$debug_str += "click generated " + conversion[:revenue].to_s + " on banner " + click[:banner_id].to_s + "\n"
                    
                    if last_banner_id == click[:banner_id]
                        banner_revenue[count-1][:revenue]  += conversion[:revenue]
                    else
                        banner_revenue[count] = {:banner_id => click[:banner_id], :revenue => conversion[:revenue]}
                        last_banner_id = click[:banner_id]
                        count += 1
                    end
                end
            end  
        end
        return banner_revenue
    end

    def get_banners_clicks(clicks_data_subset)
        banner_clicks = Array.new
        count = 0
        last_banner_id = -1
        for click in clicks_data_subset
            if last_banner_id == click[:banner_id]
                banner_clicks[count-1][:clicks] += 1
            else
                banner_clicks[count] = {:banner_id => click[:banner_id], :clicks => 1}
                last_banner_id = click[:banner_id]
                count += 1
           end
        end
        return banner_clicks
    end

    def get_banner_top10(banner_revenue, banner_clicks)
        banner_top10 = Array.new
        
        #sort revenue data by revenue amount
        banner_revenue.sort_by! {|v| v[:revenue]}
        banner_revenue.reverse!

        #sort click data by click number
        banner_clicks.sort_by! {|v| v[:clicks]}
        banner_clicks.reverse!
        
        if banner_revenue.size.to_i > 0
            count = 0
            while count < 10 && count < banner_revenue.size.to_i
                $debug_str += count.to_s + " banner=" + banner_revenue[count][:banner_id].to_s + " rev=" + banner_revenue[count][:revenue].to_s + "\n"
                banner_top10[count] = {:banner_id => banner_revenue[count][:banner_id], :revenue => banner_revenue[count][:revenue]}
                count += 1
            end
        end    

        #if less than 5 entries in top 10
        
        if banner_top10.size.to_i < 5
            place = banner_top10.size.to_i
            count = 0
            while place < 5 && place <banner_clicks.size.to_i

                i = 0
                while  i < banner_top10.size.to_i
                    if banner_top10[i][:banner_id].to_s == banner_clicks[count][:banner_id].to_s
                        count += 1
                    end
                    i += 1
                end

                banner_top10[place] = {:banner_id => banner_clicks[count][:banner_id], :revenue => 0}
                place += 1
                count += 1
            end
        end 

        #if still smaller than 5 after clicks added than fill up with random banners upto 5
        if banner_revenue.size.to_i == 0
            count = banner_top10.size.to_i
            while count < 5          
                random_banner = rand(100..500)
                $debug_str += "\nrandom banner added banner=" + random_banner.to_s + "\n"
                banner_top10[count] = {:banner_id => random_banner, :revenue => 0}
                count += 1
            end
        end
        return banner_top10
    end

    #display random banners while making sure that a banner is not showed twice the same session until all other are shown from that session
    def get_banner_to_display(banner_top10)
        session[:ads_served] ||= [] #Create a session array for ads served
        
        random_pos = -1 
            
        #clear array if all banners have been shown once or if there are more banners in the session variable due to 
        #previous run with a different dataset
        if (session[:ads_served].size.to_i == (banner_top10.size.to_i) || session[:ads_served].size > banner_top10.size)
            session[:ads_served].clear
        end
           
        #check if banner already displayed this session and don't display it again until all ads have been displayed
        while (random_pos == -1 || (session[:ads_served].include?(banner_top10[random_pos.to_i][:banner_id].to_s))) do 
            random_pos = rand(0..(banner_top10.size.to_i.to_i - 1))   
        end

        #set the banner to be displayed and add it to the session variable array
        banner_to_display = banner_top10[random_pos][:banner_id]
        count = session[:ads_served].size.to_i
        #$debug_str += "\n count = " + session[:ads_served].size.to_s
        session[:ads_served][count.to_i%banner_top10.size.to_i] = banner_to_display.to_s
        
        return banner_to_display
    end
end
