require 'rest-client'
require 'nokogiri'
require 'sanitize'

module Lita
  module Handlers
    class OnewheelBeerBase < Handler

      def taps_list(response)
        # wakka wakka
        beers = self.get_source
        reply = "taps: "
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

      def get_tap_type_text(type)
        (type.empty?) ? '' : "(#{type}) "
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

      def get_source
        raise Exception
      end

      Lita.register_handler(self)
    end
  end
end
