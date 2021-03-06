# -*- coding: utf-8 -*-
# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -*- encoding : utf-8 -*-
class Admin::QsController < ApplicationController

  # These before_filters apply the hydra access controls
  #before_filter :enforce_show_permissions, :only=>:show
  skip_before_filter :default_html_head

  def index
    @queues = {'resque:ora_publish' => 'Queue waiting to be processed by ORA to publish record in ORA and ORA-Archive'}
    @data = {}
    @queues.keys.each do |k|
      count = 0
      @data[k] = []
      while count < $redis.llen(k)
        @data[k] << $redis.lindex(k, count)
        count += 1
      end
    end
  end

end
