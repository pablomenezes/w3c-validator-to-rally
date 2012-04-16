$VERBOSE = nil

require 'rubygems'
require 'active_resource'
require 'logger'
require 'rally_rest_api'
require 'date'
require 'time'
require 'fileutils'
require 'mechanize'
require 'htmlentities'

module W3CValidatorToRally
	class W3CValidator
		def defineURI(uri)
			$URI = uri
		end

		def showURI
			puts $URI
		end

		def getURI
			return $URI
		end

		def startValidation(agentMechanize="Windows Mozilla")
			mechanize = Mechanize.new { |agent| agent.user_agent_alias = agentMechanize }
			mechanize.get("http://validator.w3.org")
			forms = mechanize.page.forms.first
			forms['uri'] = $URI
			forms.submit

			results = mechanize.page.search(".msg_err")

			puts "#{results.length} error(s) found!\n"

			errors = Array.new results.length

			index = 0

			testFirstError = results.first.elements[1].text.gsub("\n","").gsub("\t","").gsub("         ","")

			if ((results.length == 1) and (testFirstError.start_with?("        Sorry")))
				begin
					 encodeError = results.first.elements[2].text.gsub("\n","").gsub("\t","").gsub("         ","")
					 errors[index] = encodeError, "Encode error found"
				end

			else
				begin
					results.each do |mountDefect|

						teste = mountDefect.elements[1].to_s
						teste = teste.gsub(/<\/?[^>]*>/, "").gsub("\n","").gsub("        ","")

						name = mountDefect.elements[2].to_s
						name = name.gsub('<span class="msg">',"").gsub('</span>',"")
						name = name.slice(0,255)

						completeName = teste + " : " + name

						#decode = HTMLEntities.new
						description = mountDefect.elements[3].to_s
						description = description.gsub(/<\/?[^>]*>/, "").gsub("\t","")
						#description = decode.decode(description)

						errors[index] = completeName,description
						index = index + 1
					end
				end
			end

			return errors

		end
	end

	class Rally
		def connect(login,pass)
			begin
				print "Conecting with Rally...\n"
				rally_logger = Logger.new STDOUT
				rally_logger.level = Logger::INFO
				@rally = RallyRestAPI.new(:username => login, :password => pass, :api_version => "1.29", :logger => rally_logger)
			rescue
				print "Error on connect. Try again...\n"
			else
				print "Logged with success!\n"
			end
		end


		def createDefects(project,errors)

			if errors.length > 0
				begin
					puts "Checking defects"

					totals = errors.length - 1

					uri = W3CValidatorToRally::W3CValidator.new

					for index in (0..totals)

						name = errors[index].first
						description = errors[index].last + "<br /><br />URL:&nbsp;&nbsp;" + uri.getURI

						findDefect(nil,project,name,description,index)

					end
				end
			else
				puts "No errors to create"
			end
		end

		private
		def findDefect(workspace,project,name,description,index)

			proj = "https://rally1.rallydev.com/slm/webservice/1.17/project/" + project

			query_result = @rally.find(:defect,:project => ref=proj){equal :name, name}

			if query_result.total_result_count > 0
				puts "Defect #{index + 1} already exists"
			else
				begin
					puts "Defect not found. Creating defect number #{index + 1}"
					createDefect(project,name,description,index)
				end
			end
		end

		def createDefect(project,name,description,index)
			begin
				proj = "https://rally1.rallydev.com/slm/webservice/1.17/project/" + project
				params = {:project => ref=proj, :name => name, :severity => "Major Problem", :state => "Submitted", :description => description, :target_date => Date.today + 15}
				@rally.create(:defect,params)
			rescue
				puts "Error on create defect number #{index + 1}"
			else
				puts "Defect #{index + 1} created with success!"
			end
		end


	end

end
