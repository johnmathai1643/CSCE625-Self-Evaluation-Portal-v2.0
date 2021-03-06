require 'tempfile'

class ProblemsController < ApplicationController
  before_action :logged_in_instructor, only: [:new, :create, :index, :show, :edit, :update, :destroy]

  def new
    @topics = Topic.all
    @question_types = QuestionType.all
    @problem = Problem.new
    if(params[:topic_from])
      @problem[:topic_id] = params[:topic_from]
    end
  end

  def create
    @problem = Problem.new(problem_params)
    
    # handle images here ... convert to base64
    # image file upload here
    if problem_params[:img].present?
      img_file =  problem_params[:img].tempfile.open.read.force_encoding(Encoding::UTF_8)
      @problem.img = Base64.encode64(img_file)
    end

    # image file upload here, check file upload size here
    if problem_params[:img].present?
      img_file =  problem_params[:img].tempfile.open.read.force_encoding(Encoding::UTF_8)
      if (problem_params[:img].size.to_i > 65000) or !(['image/png', 'image/jpeg', 'image/jpg'].include? problem_params[:img].content_type)
        flash.now[:danger] = "Please upload a valid image file that is less than 65KB in size!"
        @topics = Topic.all
        @question_types = QuestionType.all
        @options = @problem.options
        @links = @problem.links
        render 'new'
        return
      end
      problem_params[:img] = Base64.encode64(img_file)
    else
      if params[:is_image] == 'N'
        # remove image if the user clicked on remove image in the view
        problem_params[:img] = ''
      end
    end

    #print(@problem[:question_type_id])
    id = QuestionType.find(@problem[:question_type_id])
    #print(id.question_type)
    # Problem is MCQ
    if id.question_type == "MCQ"
      #print("MCQ")
      if @problem.save
        # Save problem first to add options(Options belongs to Problems)
        flash[:success] = "Problem created."
        options = option_params
        options_not_nil = false
        if !options[:correct].nil? 
         options[:options].each do |key|
          if !options[:options][key].nil?
            options_not_nil = true
          end
          _is_answer = !options[:correct][key].nil?
          if(_is_answer && options[:options][key].empty?)
            flash.now[:danger] = "Provide answers and correct choices for MCQ."
            @topics = Topic.all
            @question_types = QuestionType.all
            @options = @problem.options
            @problem.destroy
            flash.delete(:success)
            render 'new'
            return
          end
         end
       end
        if options_not_nil && !options[:correct].nil?
          # Save all 4 options
          options[:options].each do |key|
            _is_answer = !options[:correct][key].nil?
            opt = @problem.options.create(answer: options[:options][key], is_answer: _is_answer)
            if opt.valid?
              # Option saved
            else
              flash[:danger] = "Empty options were discarded."
            end
          end
          
          # Save any links
          save_link
          
          redirect_to @problem
        else
          flash.now[:danger] = "Provide answers and correct choices for MCQ."
          @topics = Topic.all
          @question_types = QuestionType.all
          @problem.destroy
          flash.delete(:success)
          render 'new'
        end
      else
        flash.now[:danger] = "Unable to save Problem."
        @topics = Topic.all
        @question_types = QuestionType.all
        render 'new'
      end
    # Problem is short answer type
    else
      #print("Short Answer")
      if @problem[:answer].blank?
        flash.now[:danger] = "Answer can't be blank."
        @topics = Topic.all
        @question_types = QuestionType.all
        render 'new'
      elsif @problem.save
        flash[:success] = "Problem created."
        save_link
        
        redirect_to @problem
      else
        render 'new'
      end
    end
  end

  def index
    @problems = Problem.paginate(page: params[:page], :per_page =>10)
  end

  def show
    @problem = Problem.find(params[:id])
    @correct_answers = Array.new
    if(@problem.question_type.question_type == "MCQ")
      @correct_answers = @problem.options.where("is_answer = true").pluck(:answer)
    end
    if(@problem.question_type.question_type == "Short Answer")
      @correct_answers.push(@problem.answer)
    end
  end

  def edit
    @problem = Problem.find(params[:id])
    @options = @problem.options
    @topics = Topic.all
    @question_types = QuestionType.all
    @links = @problem.links
  end

  def update
    @problem = Problem.find(params[:id])

    # image file upload here, check file upload size here
    if problem_params[:img].present?
      img_file =  problem_params[:img].tempfile.open.read.force_encoding(Encoding::UTF_8)
      puts problem_params[:img].content_type
      puts problem_params[:img].size
      if (problem_params[:img].size.to_i > 65000) or !(['image/png', 'image/jpeg', 'image/jpg'].include? problem_params[:img].content_type)
        flash.now[:danger] = "Please upload a valid image file that is less than 65KB in size!"
        @topics = Topic.all
        @question_types = QuestionType.all
        @options = @problem.options
        @links = @problem.links
        render 'edit'
        return
      end
      problem_params[:img] = Base64.encode64(img_file)
    else
      if params[:is_image] == 'N'
        # remove image if the user clicked on remove image in the view
        problem_params[:img] = ''
      end
    end

    id = QuestionType.find(problem_params[:question_type_id])
    if id.question_type == "MCQ"
      options = option_params
      if @problem.update_attributes(problem_params)
        options_not_nil = false
        if !options[:correct].nil?
         options[:options].each do |key|
          if !options[:options][key].empty?
            options_not_nil = true
          end
          _is_answer = !options[:correct][key].nil?
          if(_is_answer && options[:options][key].empty?)
            flash.now[:danger] = "Provide answers and correct choices for MCQ."
            @topics = Topic.all
            @question_types = QuestionType.all
            @options = @problem.options
            @links = @problem.links
            render 'edit'
            return
          end
         end
       end
       
        if options_not_nil && !options[:correct].nil?
          @problem.options.destroy_all
          # Save all 4 options
          options[:options].each do |key|
            _is_answer = !options[:correct][key].nil?
            print "option values are #{options[:options][key]}"
            opt = @problem.options.create(answer: options[:options][key], is_answer: _is_answer)
            if opt.valid?
              # Option saved
            else
              flash[:danger] = "Empty options were discarded."
            end
          end
          # Save any links
          update_link
          flash[:success] = "Problem updated."    
          redirect_to @problem
        else
          flash.now[:danger] = "Provide answers and correct choices for MCQ."
          @topics = Topic.all
          @question_types = QuestionType.all
          @options = @problem.options
          @links = @problem.links
          render 'edit'
        end
      else
        flash.now[:danger] = "Unable to save Problem."
        @topics = Topic.all
        @question_types = QuestionType.all
        render 'edit'
      end
    else
      if problem_params[:answer].blank?
        flash.now[:danger] = "Answer can't be blank."
        @topics = Topic.all
        @question_types = QuestionType.all
        @links = @problem.links
        render 'edit'
      elsif @problem.update_attributes(problem_params)
        flash[:success] = "Problem updated."
        @problem.options.destroy_all
        update_link
        redirect_to @problem
      else
        render 'new'
      end
    end
  end

  def destroy
    topic = Problem.find(params[:id]).topic
    Problem.find(params[:id]).destroy
    flash[:success] = "Problem deleted."
    redirect_to topic
  end

  private

  def problem_params
    @problem_params ||= params.require(:problem).permit(:question, :answer, :remark, :topic_id, :question_type_id, :img, :options, :correct)
  end

  def instructor_params
    params.require(:instructor).permit(:name, :email, :password,
                                       :password_confirmation)
  end
  
  def option_params
    params.require(:problem)
  end
  
  def save_link
    link_param = params.require(:problem).permit(:link)
    
    if !link_param[:link].nil? && link_param[:link] != ""
      opt = @problem.links.create(link: link_param[:link])
      if opt
        # Link created
      else
        flash[:danger] = "Link not created."
      end
    end
  end
  
  def update_link
    link_param = params.require(:problem).permit(:link)
    
    if !link_param[:link].nil? && link_param[:link] != ""
      @problem.links.destroy_all
      opt = @problem.links.create(link: link_param[:link])
      if opt
        # Link created
      else
        flash[:danger] = "Link not created."
      end
    end
  end

  def logged_in_instructor
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
  def correct_instructor
    @instructor = Instructor.find(params[:id])
    redirect_to(root_url) unless current_instructor?(@instructor)
  end

  def admin_instructor
    redirect_to(root_url) unless current_instructor.admin?
  end
end