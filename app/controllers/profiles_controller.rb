class ProfilesController < ApplicationController
	before_filter :cors_preflight_check
  	after_filter :cors_set_access_control_headers


	def index
		#GET path to profiles - used to show people you haven't swiped on yet

		#get current user for their details
		@user = Profile.find_by_facebook_id(params[:facebook_id])
		#get what you've already swiped on
		@already_swiped = Match.where("profile_id = ?", @user['id']).pluck("swipee_id")
		if @already_swiped.empty?
			@users_close_by = Profile.find_by_sql ["SELECT * FROM profiles p WHERE earth_box(ll_to_earth(?,?),?) @> ll_to_earth(p.latitude,p.longitude) AND p.gender = ? AND p.age BETWEEN ? AND ? AND p.id != ? LIMIT 3",@user['latitude'],@user['longitude'],@user['preferred_distance'],@user['preferred_gender'],@user['preferred_min_age'],@user['preferred_max_age'],@user['facebook_id']]
		else
			@users_close_by = Profile.find_by_sql ["SELECT * FROM profiles p WHERE earth_box(ll_to_earth(?,?),?) @> ll_to_earth(p.latitude,p.longitude) AND p.gender = ? AND p.age BETWEEN ? AND ? AND p.id != ? AND p.id NOT IN (?) LIMIT 3",@user['latitude'],@user['longitude'],@user['preferred_distance'],@user['preferred_gender'],@user['preferred_min_age'],@user['preferred_max_age'],@user['facebook_id'],@already_swiped]
		end
		render json: @users_close_by
	end

	def create

		#POST path to profiles - used to create a new user (TODO write some code to prevent someone creating two profiles on a double click)
		@profile = Profile.new(profile_params)
		if @profile.save
			render json: @profile
		else
			render 'failed to save'
		end
	end

	# def show
	# 	#GET path to profiles/:id - used to show details of user
	# 	@profile = Profile.find_by_facebook_id(params[:id])
	# 	if !@profile.nil?
	# 		render json: @profile
	# 	else
	# 		render :text => '', :content_type => 'text/plain'
	# 	end
	# end
	
	def update
		#PUT/PATCH path to profiles/:id - used to update details of user

		@profile = Profile.find_by_facebook_id(params[:id])

		if picture1_url?
			@profile.picture1_from_url(params[:picture1_url])
		end
		if picture2_url?
			@profile.picture2_from_url(params[:picture2_url])
		end
		if picture3_url?
			@profile.picture3_from_url(params[:picture3_url])
		end
		if picture4_url?
			@profile.picture4_from_url(params[:picture4_url])
		end
		if picture5_url?
			@profile.picture5_from_url(params[:picture5_url])
		end

		if @profile.update(profile_params)
			render json: @profile
		else
			render 'failed to update'
		end
	end

	def destroy
		#DELETE path to profiles/:id - used to delete user
	end

	private

	def profile_params
	    params.require(:profile).permit(:facebook_id, :age, :first_name, :latitude, :longitude, :answer1, :answer2, :answer3, :answer4, :answer5, :preferred_min_age,
	   	:preferred_max_age, :preferred_gender, :preferred_sound, :preferred_distance, :male, :picture1, :picture2, :picture3, :picture4, :picture5, 
	   	:picture1_from_url, :picture2_from_url, :picture3_from_url, :picture4_from_url, :picture5_from_url)
	end

	def picture1_url?
		!params[:picture1_url].blank?
	end

	def picture2_url?
		!params[:picture2_url].blank?
	end

	def picture3_url?
		!params[:picture3_url].blank?
	end

	def picture4_url?
		!params[:picture4_url].blank?
	end

	def picture5_url?
		!params[:picture5_url].blank?
	end

end
