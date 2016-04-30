require 'spec_helper'

describe Lita::Handlers::OnewheelBaileys, lita_handler: true do
  it { is_expected.to route_command('taps') }
  it { is_expected.to route_command('taps 4') }
  it { is_expected.to route_command('taps nitro') }
  it { is_expected.to route_command('taps CASK') }
  it { is_expected.to route_command('taps <$4') }
  it { is_expected.to route_command('taps < $4') }
  it { is_expected.to route_command('taps <=$4') }
  it { is_expected.to route_command('taps <= $4') }
  it { is_expected.to route_command('taps >4%') }
  it { is_expected.to route_command('taps > 4%') }
  it { is_expected.to route_command('taps >=4%') }
  it { is_expected.to route_command('taps >= 4%') }
  it { is_expected.to route_command('tapslow') }
  it { is_expected.to route_command('tapsabvhigh') }
  it { is_expected.to route_command('tapsabvlow') }

  before do
    mock = File.open('spec/fixtures/baileys.html').read
    allow(RestClient).to receive(:get) { mock }
  end

  it 'shows the taps' do
    send_command 'taps'
    expect(replies.last).to eq("Bailey's taps: 1) Cider Riot! Plastic Paddy  2) Fox Tail Rosenberry  3) (Cask) Machine House Crystal Maze  4) Wild Ride Solidarity  5) Mazama Gillian’s Red  6) (Nitro) Backwoods Winchester Brown  7) Fort George Vortex  8) Fat Head’s Zeus Juice  9) Hopworks Noggin’ Floggin’  10) Anderson Valley Briney Melon Gose  11) Lagunitas Copper Fusion Ale  12) Double Mountain Fast Lane  13) Burnside Couch Lager  14) Bell’s Oatmeal Stout  15) Baerlic Wildcat  16) New Belgium La Folie  17) Culmination Urizen  18) Knee Deep Hop Surplus  19) Cascade Lakes Ziggy Stardust  20) Knee Deep Dark Horse  21) Coronado Orange Avenue Wit  22) GoodLife 29er  23) Amnesia Slow Train Porter  24) Oakshire Perfect Storm  25) Green Flash Passion Fruit Kicker")
  end

  it 'displays details for tap 4' do
    send_command 'taps 4'
    expect(replies.last).to eq('Bailey\'s tap 4) Wild Ride Solidarity - Abbey Dubbel – Barrel Aged (Pinot Noir) 8.2%, 4oz - $4 | 12oz - $7, 26% remaining')
  end

  it 'doesn\'t explode on 1' do
    send_command 'taps 1'
    expect(replies.count).to eq(1)
    expect(replies.last).to eq('Bailey\'s tap 1) Cider Riot! Plastic Paddy - Apple Cider w/ Irish tea 6.0%, 10oz - $4 | 20oz - $7 | 32oz Crowler - $10, 48% remaining')
  end

  it 'gets nitro' do
    send_command 'taps nitro'
    expect(replies.last).to eq('Bailey\'s tap 6) (Nitro) Backwoods Winchester Brown - Brown Ale 6.2%, 10oz - $3 | 20oz - $5, 98% remaining')
  end

  it 'gets cask' do
    send_command 'taps cask'
    expect(replies.last).to eq("Bailey's tap 3) (Cask) Machine House Crystal Maze - ESB 4.0%, 10oz - $3 | 20oz - $5, 57% remaining")
  end

  it 'searches for ipa' do
    send_command 'taps ipa'
    expect(replies.last).to eq("Bailey's tap 24) Oakshire Perfect Storm - Imperial IPA 9.0%, 10oz - $4 | 20oz - $6 | 32oz Crowler - $10, 61% remaining")
  end

  it 'searches for brown' do
    send_command 'taps brown'
    expect(replies.last).to eq("Bailey's tap 22) GoodLife 29er - India Brown Ale 6.0%, 10oz - $3 | 20oz - $5 | 32oz Crowler - $8, 37% remaining")
  end

  it 'searches for abv >9%' do
    send_command 'taps >9%'
    expect(replies.count).to eq(4)
    expect(replies[0]).to eq("Bailey's tap 8) Fat Head’s Zeus Juice - Belgian Strong Blonde 10.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $9, 44% remaining")
    expect(replies[1]).to eq("Bailey's tap 9) Hopworks Noggin’ Floggin’ - Barleywine 11.0%, 4oz - $3 | 12oz - $6 | 32oz Crowler - $13, 34% remaining")
    expect(replies[2]).to eq("Bailey's tap 18) Knee Deep Hop Surplus - Triple IPA 10.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $10, 25% remaining")
    expect(replies[3]).to eq("Bailey's tap 20) Knee Deep Dark Horse - Imperial Stout 12.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $10, 39% remaining")
  end

  it 'searches for abv > 9%' do
    send_command 'taps > 9%'
    expect(replies.count).to eq(4)
    expect(replies[0]).to eq("Bailey's tap 8) Fat Head’s Zeus Juice - Belgian Strong Blonde 10.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $9, 44% remaining")
    expect(replies[1]).to eq("Bailey's tap 9) Hopworks Noggin’ Floggin’ - Barleywine 11.0%, 4oz - $3 | 12oz - $6 | 32oz Crowler - $13, 34% remaining")
    expect(replies[2]).to eq("Bailey's tap 18) Knee Deep Hop Surplus - Triple IPA 10.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $10, 25% remaining")
    expect(replies[3]).to eq("Bailey's tap 20) Knee Deep Dark Horse - Imperial Stout 12.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $10, 39% remaining")
  end

  it 'searches for abv >= 9%' do
    send_command 'taps >= 9%'
    expect(replies.count).to eq(5)
    expect(replies[0]).to eq("Bailey's tap 8) Fat Head’s Zeus Juice - Belgian Strong Blonde 10.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $9, 44% remaining")
    expect(replies[1]).to eq("Bailey's tap 9) Hopworks Noggin’ Floggin’ - Barleywine 11.0%, 4oz - $3 | 12oz - $6 | 32oz Crowler - $13, 34% remaining")
    expect(replies[2]).to eq("Bailey's tap 18) Knee Deep Hop Surplus - Triple IPA 10.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $10, 25% remaining")
    expect(replies[3]).to eq("Bailey's tap 20) Knee Deep Dark Horse - Imperial Stout 12.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $10, 39% remaining")
    expect(replies.last).to eq("Bailey's tap 24) Oakshire Perfect Storm - Imperial IPA 9.0%, 10oz - $4 | 20oz - $6 | 32oz Crowler - $10, 61% remaining")
  end

  it 'searches for abv <4.1%' do
    send_command 'taps <4.1%'
    expect(replies.count).to eq(2)
    expect(replies[0]).to eq("Bailey's tap 3) (Cask) Machine House Crystal Maze - ESB 4.0%, 10oz - $3 | 20oz - $5, 57% remaining")
    expect(replies.last).to eq("Bailey's tap 11) Lagunitas Copper Fusion Ale - Copper Ale 4.0%, 10oz - $3 | 20oz - $5 | 32oz Crowler - $8, 19% remaining")
  end

  it 'searches for abv < 4.1%' do
    send_command 'taps < 4.1%'
    expect(replies.count).to eq(2)
    expect(replies[0]).to eq("Bailey's tap 3) (Cask) Machine House Crystal Maze - ESB 4.0%, 10oz - $3 | 20oz - $5, 57% remaining")
    expect(replies.last).to eq("Bailey's tap 11) Lagunitas Copper Fusion Ale - Copper Ale 4.0%, 10oz - $3 | 20oz - $5 | 32oz Crowler - $8, 19% remaining")
  end

  it 'searches for abv <= 4%' do
    send_command 'taps <= 4%'
    expect(replies.count).to eq(2)
    expect(replies[0]).to eq("Bailey's tap 3) (Cask) Machine House Crystal Maze - ESB 4.0%, 10oz - $3 | 20oz - $5, 57% remaining")
    expect(replies.last).to eq("Bailey's tap 11) Lagunitas Copper Fusion Ale - Copper Ale 4.0%, 10oz - $3 | 20oz - $5 | 32oz Crowler - $8, 19% remaining")
  end

  it 'searches for prices >$6' do
    send_command 'taps >$6'
    expect(replies.count).to eq(2)
    expect(replies[0]).to eq("Bailey's tap 1) Cider Riot! Plastic Paddy - Apple Cider w/ Irish tea 6.0%, 10oz - $4 | 20oz - $7 | 32oz Crowler - $10, 48% remaining")
    expect(replies[1]).to eq("Bailey's tap 4) Wild Ride Solidarity - Abbey Dubbel – Barrel Aged (Pinot Noir) 8.2%, 4oz - $4 | 12oz - $7, 26% remaining")
  end

  it 'searches for prices >=$6' do
    send_command 'taps >=$6'
    expect(replies.count).to eq(4)
    expect(replies[0]).to eq("Bailey's tap 1) Cider Riot! Plastic Paddy - Apple Cider w/ Irish tea 6.0%, 10oz - $4 | 20oz - $7 | 32oz Crowler - $10, 48% remaining")
    expect(replies[1]).to eq("Bailey's tap 4) Wild Ride Solidarity - Abbey Dubbel – Barrel Aged (Pinot Noir) 8.2%, 4oz - $4 | 12oz - $7, 26% remaining")
    expect(replies[2]).to eq("Bailey's tap 9) Hopworks Noggin’ Floggin’ - Barleywine 11.0%, 4oz - $3 | 12oz - $6 | 32oz Crowler - $13, 34% remaining")
    expect(replies[3]).to eq("Bailey's tap 24) Oakshire Perfect Storm - Imperial IPA 9.0%, 10oz - $4 | 20oz - $6 | 32oz Crowler - $10, 61% remaining")
  end

  it 'searches for prices > $6' do
    send_command 'taps > $6'
    expect(replies.count).to eq(2)
    expect(replies[0]).to eq("Bailey's tap 1) Cider Riot! Plastic Paddy - Apple Cider w/ Irish tea 6.0%, 10oz - $4 | 20oz - $7 | 32oz Crowler - $10, 48% remaining")
    expect(replies[1]).to eq("Bailey's tap 4) Wild Ride Solidarity - Abbey Dubbel – Barrel Aged (Pinot Noir) 8.2%, 4oz - $4 | 12oz - $7, 26% remaining")
  end

  it 'searches for prices <$4.1' do
    send_command 'taps <$4.1'
    expect(replies.count).to eq(3)
    expect(replies[0]).to eq("Bailey's tap 8) Fat Head’s Zeus Juice - Belgian Strong Blonde 10.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $9, 44% remaining")
    expect(replies[1]).to eq("Bailey's tap 18) Knee Deep Hop Surplus - Triple IPA 10.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $10, 25% remaining")
    expect(replies[2]).to eq("Bailey's tap 20) Knee Deep Dark Horse - Imperial Stout 12.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $10, 39% remaining")
  end

  it 'searches for prices < $4.01' do
    send_command 'taps < $4.01'
    expect(replies.count).to eq(3)
    expect(replies[0]).to eq("Bailey's tap 8) Fat Head’s Zeus Juice - Belgian Strong Blonde 10.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $9, 44% remaining")
    expect(replies[1]).to eq("Bailey's tap 18) Knee Deep Hop Surplus - Triple IPA 10.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $10, 25% remaining")
    expect(replies[2]).to eq("Bailey's tap 20) Knee Deep Dark Horse - Imperial Stout 12.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $10, 39% remaining")
  end

  it 'searches for prices <= $4.00' do
    send_command 'taps <= $4.00'
    expect(replies.count).to eq(3)
    expect(replies[0]).to eq("Bailey's tap 8) Fat Head’s Zeus Juice - Belgian Strong Blonde 10.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $9, 44% remaining")
    expect(replies[1]).to eq("Bailey's tap 18) Knee Deep Hop Surplus - Triple IPA 10.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $10, 25% remaining")
    expect(replies[2]).to eq("Bailey's tap 20) Knee Deep Dark Horse - Imperial Stout 12.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $10, 39% remaining")
  end

  it 'runs a random beer through' do
    send_command 'taps roulette'
    expect(replies.count).to eq(1)
    expect(replies.last).to include("Bailey's tap")
  end

  it 'runs a random beer through' do
    send_command 'taps random'
    expect(replies.count).to eq(1)
    expect(replies.last).to include("Bailey's tap")
  end

  it 'searches with a space' do
    send_command 'taps zeus juice'
    expect(replies.last).to eq("Bailey's tap 8) Fat Head’s Zeus Juice - Belgian Strong Blonde 10.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $9, 44% remaining")
  end

  it 'displays low taps' do
    send_command 'tapslow'
    expect(replies.last).to eq("Bailey's tap 25) Green Flash Passion Fruit Kicker - Wheat Ale w/ Passion Fruit 5.5%, 10oz - $3 | 20oz - $5, <= 1% remaining")
  end

  it 'displays low abv' do
    send_command 'tapsabvhigh'
    expect(replies.last).to eq("Bailey's tap 20) Knee Deep Dark Horse - Imperial Stout 12.0%, 4oz - $2 | 12oz - $4 | 32oz Crowler - $10, 39% remaining")
  end

  it 'displays high abv' do
    send_command 'tapsabvlow'
    expect(replies.last).to eq("Bailey's tap 3) (Cask) Machine House Crystal Maze - ESB 4.0%, 10oz - $3 | 20oz - $5, 57% remaining")
  end
end
