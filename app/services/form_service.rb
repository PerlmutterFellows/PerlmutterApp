class FormService
  def initialize
    set_form(I18n.t('form'))
    set_score([])
    set_subscores({})
  end

  def valid?
    @form.kind_of?(Array) && @form.count != 0
  end

  def valid_answer?(answered_questions, question_index)
    !answered_questions[question_index.to_s].blank?
  end

  def get_form
    @form
  end

  def set_form(form)
    @form = form
  end

  def get_form_sequence
    (0...self.get_form.length)
  end

  def get_question(question_index)
    @form[question_index][:question]
  end

  def get_numbered_question_string(question_index)
    "#{question_index+1}. #{get_question(question_index)}"
  end

  def get_max_value(question_index)
    @form[question_index][:max_value]
  end

  def get_subscores_arr(question_index)
    @form[question_index][:subscores]
  end

  def get_answer(question_index, answer_index)
    @form[question_index][:answers][answer_index]
  end

  def get_answer_index(answered_questions, question_index)
    answered_questions[question_index.to_s].to_i
  end

  def get_score(answered_questions)
    if @score.empty?
      score = 0
      max_score = 0
      self.get_form_sequence.each do |index|
          if self.valid_answer?(answered_questions, index)
            value = self.get_answer(index, get_answer_index(answered_questions, index))[:value]
            unless value.blank?
              score += value
              max_score += get_max_value(index)
              subscores_arr = self.get_subscores_arr(index)
              if subscores_arr.kind_of?(Array) && subscores_arr.count != 0
                subscores_arr.each do |subscore|
                  if @subscores[subscore].blank?
                    @subscores[subscore] = [value, get_max_value(index)]
                  else
                    @subscores[subscore] = [@subscores[subscore][0] + value, @subscores[subscore][1] + get_max_value(index)]
                  end
                end
              end
            end
          end
      end
      @score = [score, max_score]
    end
    @score
  end

  def get_subscore_string(key)
    if key.downcase == "score"
      score = @score
    else
      score = @subscores[key]
    end
    ["#{key.upcase_first}:", "#{score[0].round}/#{score[1].round}"]
  end

  def get_score_string
    get_subscore_string("score")
  end

  def set_score(score)
    @score = score
  end

  def get_subscores
    @subscores
  end

  def set_subscores(subscores)
    @subscores = subscores
  end

  def get_answer_string_with_score(question_index, answer_index)
    answer = get_answer(question_index, answer_index)
    suffix = ""
    unless answer[:value].blank?
      suffix = " (#{answer[:value]}/#{get_max_value(question_index)})"
    end
    "#{answer[:text]}#{suffix}"
  end
end
