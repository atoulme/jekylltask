# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with this
# work for additional information regarding copyright ownership.  The ASF
# licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.

require File.join(File.dirname(__FILE__), "..", "lib", "jekylltask")

describe JekyllTask do
  
  before(:each) do
    @original_dir = Dir.pwd
    mkdir_p File.join(@original_dir, '_tmp', 'doc')
    Dir.chdir File.join(@original_dir, '_tmp')
    File.open("doc/file.textile", "w") do |f|
      f.write <<-TXT
---
title: Page title
---

h2. My title

|This|is|a|simple|table|
|This|is|a|simple|row|
      
TXT
    end
    File.open("doc/_config.yml", "w") do |f|
      f.puts "pygments: true"
    end
  end
  
  after(:each) do
    Dir.chdir @original_dir
    rm_rf File.join(@original_dir, '_tmp')
  end
  
  it 'should generate a html file from a textile file' do
    
    JekyllTask.new :jekyll do |task|
      task.source = 'doc'
      task.target = '_site'
      
    end
    
    lambda { task('jekyll').invoke }.should change { File.exist? "_site/file.html" }.from(false).to(true)
  end
end
