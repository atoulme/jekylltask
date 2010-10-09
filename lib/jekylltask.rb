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

require 'rake/tasklib'
require 'jekyll'

class JekyllTask < Rake::TaskLib
  def initialize(name) # :yield: self
    @name = name
    @source = nil
    @target = nil
    @auto = false
    @description = nil
    yield self if block_given?
    raise "User must specify source directory" unless self.source
    raise "User must specify target directory" unless self.target
    generate
  end

  attr_reader :name
  attr_accessor :source
  attr_accessor :target
  attr_accessor :auto
  attr_accessor :description

  private

  def generate
    desc self.description if self.description
    if self.auto
      task self.name do
        require 'directory_watcher'
        puts "Auto generating: just edit a page and save, watch the console to see when we're done regenerating pages"
        dw = DirectoryWatcher.new(source)
        dw.interval = 1
        dw.glob = Dir.chdir(source) do
          dirs = Dir['*'].select { |x| File.directory?(x) }
          dirs -= [target]
          dirs = dirs.map { |x| "#{x}/**/*" }
          dirs += ['*']
        end
        dw.start
        site = init_jekyll
        dw.add_observer do |*args|
          t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          puts "[#{t}] regeneration: #{args.size} files changed"
          site.process
          puts "Done"
        end
        loop { sleep 1 }
      end
    else
      task self.name => self.target
      file self.target => FileList["#{self.source}/**/*"] do
        puts "Generating documentation in #{target}"
        site = init_jekyll
        site.process
        touch target
      end
    end
    task 'clobber' do
      rm_rf self.target
    end
  end

  def init_jekyll
    options = {'source' => self.source, 'destination' => self.target}
    options = Jekyll.configuration(options)
    Jekyll::Site.new(options)
  end
end

