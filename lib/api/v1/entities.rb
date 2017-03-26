module API
  module V1
    module Entities
      class Base < Grape::Entity
        format_with(:null) { |v| v.blank? ? "" : v }
        format_with(:chinese_date) { |v| v.blank? ? "" : v.strftime('%Y-%m-%d') }
        format_with(:chinese_datetime) { |v| v.blank? ? "" : v.strftime('%Y-%m-%d %H:%M:%S') }
        format_with(:chinese_time) { |v| v.blank? ? "" : v.strftime('%H:%M') }
        format_with(:money_format) { |v| v.blank? ? 0 : ('%.2f' % v).to_f }
        expose :id
        # expose :created_at, format_with: :chinese_datetime
      end # end Base
      
      # 版本信息
      class AppVersion < Base
        expose :version
        expose :app_download_url do |model, opts|
          if model.file
            model.file.url
          else
            ''
          end
        end
        expose :must_upgrade
        expose :link do |model, opts|
          model.version_summary_url
        end
      end
      
      class User < Base
        expose :uid, format_with: :null
        expose :private_token, as: :token, format_with: :null
      end
      
      # 用户基本信息
      class UserProfile < User
        expose :uid, format_with: :null
        expose :avatar do |model, opts|
          model.avatar.blank? ? "" : model.avatar_url(:large)
        end
        expose :balance
        expose :total_earn
        expose :invites_count
      end
      
      # 订单
      class Order < Base
        expose :order_no
        expose :product_title, as: :title
        expose :product_small_image, as: :image
        expose :quantity
        expose :product_price, as: :price
        expose :total_fee
        expose :state_info, as: :state
        expose :created_at, as: :time, format_with: :chinese_datetime
      end
      
      # 收益明细
      class EarnLog < Base
        expose :title
        expose :earn
        expose :unit
        expose :created_at, as: :time, format_with: :chinese_datetime
      end
      
      
      class AppTask < Base
        expose :task_id, as: :id
        expose :icon do |model, opts|
          model.app.icon ? model.app.icon.url(:big) : ''
        end
        expose :app_id do |model, opts|
          model.app.app_id
        end
        expose :app_name do |model, opts|
          model.app.name
        end
        expose :bundle_id do |model, opts|
          model.app.bundle_id
        end
        expose :appstore_url do |model, opts|
          model.app.appstore_url
        end
        expose :url_scheme do |model, opts|
          model.app.url_scheme || ''
        end
        expose :name, :keywords, :task_steps
        expose :price
        expose :special_price
        expose :put_in_count
        expose :grab_count
        # expose :in_progress do |model, opts|
        #   if opts[:ip] && opts[:uid]
        #     model.in_progress?(opts[:uid], opts[:ip])
        #   else
        #     false
        #   end
        # end
        expose :start_time, format_with: :chinese_time
      end
      
      class AppTaskDetail < AppTask
        expose :task_log_id do |model, opts|
          opts[:log_id] || opts[:opts][:log_id]
        end
        expose :expire do |model, opts|
          opts[:expire_time] || opts[:opts][:expire_time]
        end
      end
      
      class EarningDetail < Base
        expose :icon do |model, opts|
          model.app_task.app.icon.url(:big)
        end
        expose :app_name do |model, opts|
          model.app_task.app.name
        end
        expose :keywords do |model, opts|
          model.app_task.keywords
        end
        expose :money
        expose :created_at, as: :time, format_with: :chinese_datetime
      end
      
      # 收益摘要
      class EarnSummary < Base
        expose :task_type do |m, opts|
          ::EarnLog::TASK_TYPES.index(m.earnable_type) + 1
        end
        expose :task_name do |m,opts|
          ::EarnLog.task_name(m.earnable_type)
        end
        expose :total
      end
      
      # 积分墙渠道
      class Channel < Base
        expose :name, :title
        expose :subtitle, format_with: :null
        expose :icon do |model, opts|
          if model.icon
            model.icon.url(:large)
          else
            ''
          end
        end
      end
      
      # 关注任务
      class FollowTask < Base
        expose :icon do |model, opts|
          if model.icon
            model.icon.url(:large)
          else
            ''
          end
        end
        expose :gzh_name, :gzh_id
        expose :gzh_intro do |model, opts|
          model.gzh_intro || '7天内不能取消关注'
        end
        expose :earn, as: :income
        expose :link do |model, opts|
          uid = opts[:opts][:uid]
          model.task_detail_url_for(uid)
        end
      end
      
      # 分享任务
      class ShareTask < Base
        expose :icon do |model, opts|
          if model.icon
            model.icon.url(:large)
          else
            ''
          end
        end
        expose :title
        expose :earn, as: :income
        expose :first_open_earn, as: :first_open_income
        expose :link
        expose :left_count do |model, opts|
          [model.quantity - model.visit_count, 0].max
        end
        expose :my_total_income do |model, opts|
          uid = opts[:opts][:uid]
          model.my_total_income_for(uid)
        end
        expose :share_icon do |model, opts|
          if model.icon
            model.icon.url(:large)
          else
            ''
          end
        end
        expose :share_link do |model, opts|
          model.format_share_link_for(opts[:opts][:uid])
        end
        expose :share_content do |model, opts|
          model.format_share_content_for(opts[:opts][:uid])
        end
      end
      
      # 消息
      class Message < Base
        expose :title do |model, opts|
          model.title || '系统公告'
        end#, format_with: :null
        expose :content, as: :body
        expose :created_at, format_with: :chinese_datetime
      end
      
      class PayHistory < Base
        expose :pay_name, format_with: :null
        expose :created_at, format_with: :chinese_datetime
        expose :pay_money do |model, opts|
          if model.pay_type == 0
            "+ ¥ #{model.money}"
          elsif model.pay_type == 1
            "- ¥ #{model.money}"
          else
            if model.pay_name == '打赏别人'
              "- ¥ #{model.money}"
            else
              "+ ¥ #{model.money}" # 收到打赏
            end
          end
        end
      end
      
      class Author < Base
        expose :nickname do |model, opts|
          model.nickname || model.mobile
        end
        expose :avatar do |model, opts|
          model.avatar.blank? ? "" : model.avatar_url(:large)
        end
      end
      
      # 提现
      class Withdraw < Base
        expose :bean, :fee
        expose :total_beans do |model, opts|
          model.bean + model.fee
        end
        expose :pay_type do |model, opts|
          if model.account_type == 1
            "微信提现"
          elsif model.account_type == 2
            "支付宝提现"
          else
            ""
          end
        end
        expose :state_info, as: :state
        expose :created_at, as: :time, format_with: :chinese_datetime
        expose :user, using: API::V1::Entities::Author
      end
      
      # Banner
      class Banner < Base
        expose :image do |model, opts|
          model.image.blank? ? "" : model.image.url(:large)
        end
        expose :link, format_with: :null
      end
    
    end
  end
end
