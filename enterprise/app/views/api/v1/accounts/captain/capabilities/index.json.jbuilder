json.array! @capabilities do |capability|
  json.id capability[:id]
  json.title capability[:title]
  json.description capability[:description]
  json.domain capability[:domain]
  json.exposure capability[:exposure]
  json.webmcp_mode capability[:webmcp_mode]
  json.copilot_execution capability[:copilot_execution]
  json.requires_page_context capability[:requires_page_context]
  json.permission capability[:permission]
  json.route capability[:route]
  json.params capability[:params] || {}
  json.handler capability[:handler] || {}
end
