module API
  module V1
    class UsersAPI < Grape::API
      resource :account, desc: '账号相关接口' do
        desc '创建账号'
        params do
          requires :udid, type: String, desc: '用户设备ID'
        end
        post :signup do
          @user = User.find_by(udid: params[:udid])
          unless @user.blank?
            return render_error(1001, '该用户已经存在')
          end
          
          @user = User.create!(udid: params[:udid])
          render_json(@user, API::V1::Entities::User)
        end # end signup
        
        desc '绑定微信'
        params do
          requires :token, type: String, desc: '用户认证Token'
          requires :code,  type: String, desc: '微信验证码'
        end
        post :bind do
          render_json_no_data
        end # end bind
        
      end # end account resource
      
      resource :user, desc: '用户相关接口' do
        desc '获取用户的个人资料'
        params do
          requires :token, type: String, desc: '用户认证Token'
        end
        get :me do
          user = authenticate!
          if user.blank?
            return render_error(4004, '该用户不存在')
          end
          
          render_json(user, API::V1::Entities::UserProfile)
        end # end get me
      end # end user resource
      
    end # end class 
  end # end module v1
end # end API 