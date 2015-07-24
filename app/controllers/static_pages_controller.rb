require 'lol'

class StaticPagesController < ApplicationController
  def home
    @summoners = get_solo_queue_rank_for("na", "wheatbox", "bronziebox", "cheezebox", "plzdntkilme", "brotharhett")
    @summoners << get_solo_queue_rank_for("lan", "hallonoops", "handsomemanna")
    @summoners.flatten!
  end

  private

    def get_solo_queue_rank_for(region, *names)
      client = Lol::Client.new ENV["RIOT_API_KEY"], { region: region }
      summoners = client.summoner.by_name(*names)
      summoner_ids = []
      summoners.each do |summoner|
        summoner_ids << summoner.id
      end
      league_entries = client.league.get_entries(summoner_ids)
      summoner_entries = []
      summoners.each do |summoner|
        league_entries["#{summoner.id}"].each do |entry|
          if entry.queue == "RANKED_SOLO_5x5"
            summoner_entries << { name: summoner.name, tier: entry.tier.capitalize,
                                  division: entry.entries[0].division,
                                  points: entry.entries[0].league_points }
          end
        end
      end
      summoner_entries
    end
end
