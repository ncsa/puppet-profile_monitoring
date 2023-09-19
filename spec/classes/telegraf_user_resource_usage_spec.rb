# frozen_string_literal: true

require 'spec_helper'

describe 'profile_monitoring::telegraf_user_resource_usage' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
    end
  end
end
