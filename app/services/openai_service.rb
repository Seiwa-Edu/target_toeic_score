require 'openai'

class OpenaiService
  MAX_RETRIES = 3
  RETRY_DELAY = 100 # increased to 60 seconds

  def initialize
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def generate_study_plan(user)
    retries = 0
    begin
      prompt = create_prompt(user)
      
      response = @client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { role: "system", content: "You are a TOEIC expert and study planner. Create detailed daily study tasks." },
            { role: "user", content: prompt }
          ],
          temperature: 0.7,
          max_tokens: 1000
        }
      )

      parse_response(response)
    rescue OpenAI::Error => e
      if e.message.include?('429') && retries < MAX_RETRIES
        retries += 1
        wait_time = RETRY_DELAY * retries # Progressive delay
        Rails.logger.info "Rate limit hit, waiting #{wait_time} seconds before retry #{retries}/#{MAX_RETRIES}"
        sleep(wait_time)
        retry
      else
        handle_error(e)
      end
    end
  end

  private

  def create_prompt(user)
    <<~PROMPT
      Create a detailed daily study plan for TOEIC preparation with the following information:
      - Current TOEIC score: #{user.current_score}
      - Target TOEIC score: #{user.target_score}
      - Available study hours per day: #{user.study_hours}
      - Target date: #{user.target_date}

      Please provide specific tasks that can be completed within the available time,
      focusing on all TOEIC sections (Listening and Reading).
      Format the response as a JSON array of tasks, each with a title and description.
      Limit the response to 3 focused tasks that can be completed within the specified study hours.
      Keep descriptions concise but specific.
    PROMPT
  end

  def parse_response(response)
    content = response.dig("choices", 0, "message", "content")
    JSON.parse(content)
  rescue JSON::ParserError
    [{
      "title" => "Review study plan",
      "description" => "The AI response format was unexpected. Please try again or contact support."
    }]
  end

  def handle_error(error)
    case error.message
    when /429/
      [{
        "title" => "Service temporarily unavailable",
        "description" => "The study plan generator is experiencing high demand. Please wait 1-2 minutes before trying again. (Retry attempt #{Time.current.strftime('%H:%M:%S')})"
      }]
    else
      Rails.logger.error "OpenAI API Error: #{error.message}"
      [{
        "title" => "Error generating study plan",
        "description" => "An unexpected error occurred. Please try again later or contact support. Error: #{error.message}"
      }]
    end
  end
end 