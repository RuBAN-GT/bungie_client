# frozen_string_literal: true

require 'spec_helper'

describe BungieClient::Service do
  it 'returns normal service without exceptions' do
    expect { BungieClient::Service.new('get_current_user') }.to_not raise_error
  end
end
