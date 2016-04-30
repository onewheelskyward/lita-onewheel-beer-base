require 'rest-client'
require 'nokogiri'
require 'sanitize'

module Lita
  module Handlers
    class OnewheelBaileys < Handler
      route /^taps$/i,
            :taps_list,
            command: true,
            help: {'taps' => 'Display the current taps at baileys.'}

      route /^taps ([\w ]+)$/i,
            :taps_deets,
            command: true,
            help: {'taps 4' => 'Display the tap 4 deets, including prices.'}

      route /^taps ([<>=\w.\s]+)%$/i,
            :taps_by_abv,
            command: true,
            help: {'taps >4%' => 'Display beers over 4% ABV.'}

      route /^taps ([<>=\$\w.\s]+)$/i,
            :taps_by_price,
            command: true,
            help: {'taps <$5' => 'Display beers under $5.'}

      route /^taps (roulette|random)$/i,
            :taps_by_random,
            command: true,
            help: {'taps roulette' => 'Can\'t decide?  Let me do it for you!'}

      route /^tapslow$/i,
            :taps_by_remaining,
            command: true,
            help: {'tapslow' => 'Show me the kegs at <10% remaining, or the lowest one available.'}

      route /^tapsabvlow$/i,
            :taps_low_abv,
            command: true,
            help: {'tapslow' => 'Show me the lowest abv keg.'}

      route /^tapsabvhigh$/i,
            :taps_high_abv,
            command: true,
            help: {'tapslow' => 'Show me the highest abv keg.'}

      def taps_list(response)
        beers = get_source
        reply = "Bailey's taps: "
        beers.each do |tap, datum|
          reply += "#{tap}) "
          reply += get_tap_type_text(datum[:type])
          reply += datum[:brewery] + ' '
          reply += datum[:name] + '  '
        end
        reply = reply.strip.sub /,\s*$/, ''

        Lita.logger.info "Replying with #{reply}"
        response.reply reply
      end

      def taps_deets(response)
        Lita.logger.debug "taps_deets started"
        beers = get_source
        beers.each do |tap, datum|
          query = response.matches[0][0].strip
          # Search directly by tap number OR full text match.
          # Let's make cask and nitro taps specific.
          if (query.match(/^\d+$/) and tap == query) or (datum[:search].match(/#{query}/i)) or (datum[:type].downcase.match(/#{query}/i))  # Cask and Nitro
            send_response(tap, datum, response)
          end
        end
      end

      def taps_by_abv(response)
        beers = get_source
        beers.each do |tap, datum|
          if datum[:abv].to_f == 0.0
            next
          end
          query = response.matches[0][0].strip
          # Search directly by abv matcher.
          if (abv_matches = query.match(/([><=]+)\s*(\d+\.*\d*)/))
            direction = abv_matches.to_s.match(/[<>=]+/).to_s
            abv_requested = abv_matches.to_s.match(/\d+.*\d*/).to_s
            if direction == '>' and datum[:abv].to_f > abv_requested.to_f
              send_response(tap, datum, response)
            end
            if direction == '<' and datum[:abv].to_f < abv_requested.to_f
              send_response(tap, datum, response)
            end
            if direction == '>=' and datum[:abv].to_f >= abv_requested.to_f
              send_response(tap, datum, response)
            end
            if direction == '<=' and datum[:abv].to_f <= abv_requested.to_f
              send_response(tap, datum, response)
            end
          end
        end
      end

      def taps_by_price(response)
        beers = get_source
        beers.each do |tap, datum|
          # if datum[:prices][1][:cost].to_f == 0.0
          #   next
          # end

          query = response.matches[0][0].strip
          # Search directly by tap number OR full text match.
          if (price_matches = query.match(/([><=]+)\s*\$(\d+\.*\d*)/))
            direction = price_matches.to_s.match(/[<>=]+/).to_s
            price_requested = price_matches.to_s.match(/\d+.*\d*/).to_s
            if direction == '>' and datum[:prices][1][:cost].to_f > price_requested.to_f
              send_response(tap, datum, response)
            end
            if direction == '<' and datum[:prices][1][:cost].to_f < price_requested.to_f
              send_response(tap, datum, response)
            end
            if direction == '>=' and datum[:prices][1][:cost].to_f >= price_requested.to_f
              send_response(tap, datum, response)
            end
            if direction == '<=' and datum[:prices][1][:cost].to_f <= price_requested.to_f
              send_response(tap, datum, response)
            end
          end
        end
      end

      def taps_by_random(response)
        beers = get_source
        beer = beers.to_a.sample
        send_response(beer[0], beer[1], response)
      end

      def taps_by_remaining(response)
        beers = get_source
        response_sent = false
        low_tap = nil
        beers.each do |tap, datum|
          unless low_tap
            low_tap = tap
          end
          if low_tap and beers[low_tap][:remaining] > datum[:remaining]
            low_tap = tap
          end
          if datum[:remaining].to_i <= 10
            send_response(tap, datum, response)
            response_sent = true
          end
        end
      end

      def taps_low_abv(response)
        beers = get_source
        low_tap = nil
        beers.each do |tap, datum|
          unless low_tap
            low_tap = tap
          end
          if datum[:abv] != 0 and beers[low_tap][:abv] > datum[:abv]
            low_tap = tap
          end
        end
        send_response(low_tap, beers[low_tap], response)
      end

      def taps_high_abv(response)
        beers = get_source
        high_tap = nil
        beers.each do |tap, datum|
          unless high_tap
            high_tap = tap
          end
          if datum[:abv] != 0 and beers[high_tap][:abv] < datum[:abv]
            high_tap = tap
          end
        end
        send_response(high_tap, beers[high_tap], response)
      end

      def send_response(tap, datum, response)
        reply = "Bailey's tap #{tap}) #{get_tap_type_text(datum[:type])}"
        reply += "#{datum[:brewery]} "
        reply += "#{datum[:name]} "
        reply += "- #{datum[:desc]}, "
        # reply += "Served in a #{datum[1]['glass']} glass.  "
        reply += "#{get_display_prices datum[:prices]}, "
        reply += "#{datum[:remaining]}"

        Lita.logger.info "send_response: Replying with #{reply}"

        response.reply reply
      end

      def get_tap_type_text(type)
        (type.empty?) ? '' : "(#{type}) "
      end

      def get_display_prices(prices)
        price_array = []
        prices.each do |p|
          price_array.push "#{p[:size]} - $#{p[:cost]}"
        end
        price_array.join ' | '
      end

      def get_source
        Lita.logger.debug "get_source started"
        unless (response = redis.get('page_response'))
          Lita.logger.info 'No cached result found, fetching.'
          response = RestClient.get('http://www.baileystaproom.com/draft-list/')
          redis.setex('page_response', 1800, response)
        end
        response.gsub! '<div id="responsecontainer"">', ''
        parse_response response
      end

      # This is the worker bee- decoding the html into our "standard" document.
      # Future implementations could simply override this implementation-specific
      # code to help this grow more widely.
      def parse_response(response)
        Lita.logger.debug "parse_response started."
        gimme_what_you_got = {}
        noko = Nokogiri.HTML response
        noko.css('div#boxfielddata').each do |beer_node|
          # gimme_what_you_got
          tap_name = get_tap_name(beer_node)
          tap = tap_name.match(/\d+/).to_s
          tap_type = tap_name.match(/(cask|nitro)/i).to_s

          remaining = beer_node.attributes['title'].to_s

          brewery = get_brewery(beer_node)
          beer_name = beer_node.css('span i').first.children.to_s
          beer_desc = get_beer_desc(beer_node)
          abv = get_abv(beer_desc)
          full_text_search = "#{tap.sub /\d+/, ''} #{brewery} #{beer_name} #{beer_desc.to_s.gsub /\d+\.*\d*%*/, ''}"
          prices = get_prices(beer_node)

          Lita.logger.debug "Adding tap #{tap}"

          gimme_what_you_got[tap] = {
              type: tap_type,
              remaining: remaining,
              brewery: brewery.to_s,
              name: beer_name.to_s,
              desc: beer_desc.to_s,
              abv: abv.to_f,
              prices: prices,
              search: full_text_search
          }
        end
        gimme_what_you_got
      end

      def get_abv(beer_desc)
        if (abv_matches = beer_desc.match(/\d+\.\d+%/))
          abv_matches.to_s.sub '%', ''
        end
      end

      # Return the desc of the beer, "Amber ale 6.9%"
      def get_beer_desc(noko)
        beer_desc = ''
        if (beer_desc_matchdata = noko.to_s.gsub(/\n/, '').match(/(<br\s*\/*>)(.+%) /))
          beer_desc = beer_desc_matchdata[2].gsub(/\s+/, ' ').strip
        end
        beer_desc
      end

      # Get the brewery from the node, return it or blank.
      def get_brewery(noko)
        brewery = ''
        if (node = noko.css('span a').first)
          brewery = node.children.to_s.gsub(/\n/, '')
          brewery.gsub! /RBBA/, ''
          brewery.strip!
        end
        brewery
      end

      # Returns ...
      # There are a bunch of hidden html fields that get stripped after sanitize.
      def get_prices(noko)
        prices_str = noko.css('div#prices').children.to_s.strip
        prices = Sanitize.clean(prices_str)
            .gsub(/We're Sorry/, '')
            .gsub(/Inventory Restriction/, '')
            .gsub(/Inventory Failure/, '')
            .gsub('Success!', '')
            .gsub(/\s+/, ' ')
            .strip
        price_points = prices.split(/\s\|\s/)
        prices_array = []
        price_points.each do |price|
          size = price.match /\d+(oz|cl)/
          dollars = price.match(/\$\d+\.*\d*/).to_s.sub('$', '')
          crowler = price.match ' Crowler'
          size = size.to_s + crowler.to_s
          p = {size: size, cost: dollars}
          prices_array.push p
        end
        prices_array
      end

      # Returns 1, 2, Cask 3, Nitro 4...
      def get_tap_name(noko)
        noko.css('span')
            .first
            .children
            .first
            .to_s
            .match(/[\w ]+\:/)
            .to_s
            .sub(/\:$/, '')
      end

      Lita.register_handler(self)
    end
  end
end
