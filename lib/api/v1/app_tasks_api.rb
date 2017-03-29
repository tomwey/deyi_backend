module API
  module V1
    class AppTasksAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :tasks, desc: '应用任务相关接口' do
        desc '获取任务列表'
        params do
          requires :token, type: String, desc: '认证Token'
        end
        get :list do
          user = authenticate!
          
          @current = AppTask.on_sale.current.sorted.recent
          @after   = AppTask.on_sale.after.sorted.recent
          @done    = AppTask.joins(:task_orders).where('task_orders.user_id = ?', user.id).order('task_orders.created_at desc')
          
          { code: 0, message: 'ok', data: { current: API::V1::Entities::AppTaskDetail.represent(@current), 
                                            after: API::V1::Entities::AppTask.represent(@after), 
                                            done: API::V1::Entities::AppTask.represent(@done) } }
        end # end get home
        
        desc "获取任务详情"
        params do
          requires :token, type: String, desc: '用户认证Token' 
        end
        get '/:task_id' do
          authenticate!

          task = AppTask.find_by(task_id: params[:task_id])
          if task.blank?
            return render_error(4004, '任务不存在')
          end
          
          render_json(task, API::V1::Entities::AppTaskDetail)
        end
        
        desc "抢任务"
        params do
          requires :token, type: String, desc: '用户认证Token'
        end
        post '/:task_id/grab' do
          user = authenticate!
          
          task = AppTask.find_by(task_id: params[:task_id])
          if task.blank?
            return render_error(4004, '任务不存在')
          end
          
          # 是否有进行中的任务
          has_order = task.task_orders.where(state: 'pending').count > 0
          if has_order
            return render_error(1006, '有进行中的任务')
          end
          
          # ip = client_ip
          # 是否该任务还有库存
          if task.stock == 0
            return render_error(1006, '任务已经被抢光了')
          end
          
          # 下单
          order = TaskOrder.create!(app_task: task, user: user, price: task.price, special_price: task.special_price)
          
          render_json(order.app_task, API::V1::Entities::AppTaskDetail)
        end # end grab
        
        desc "开始任务"
        params do
          requires :token, type: String, desc: '用户认证Token'
          requires :oid,   type: String, desc: '任务流水号'
        end
        post '/:task_id/begin' do
          user = authenticate!
          
          task = AppTask.find_by(task_id: params[:task_id])
          if task.blank?
            return render_error(4004, '任务不存在')
          end
          
          order = task.task_orders.find_by(order_no: params[:oid])
          if order.blank?
            return render_error(4004, '您还未抢到该任务')
          end
          
          if order.expired?
            return render_error(1008, '抢到的任务已经过期，不能取消')
          end
          
          if order.completed?
            return render_error(1009, '任务已经提交完成，不能取消')
          end
          
          order.commited_at = Time.zone.now + 3.minutes
          if order.save
            render_json_no_data
          else
            render_error(1013, '任务启动失败')
          end
          
        end
        
        desc "放弃任务"
        params do
          requires :token, type: String, desc: '用户认证Token'
          requires :oid,   type: String, desc: '任务流水号'
        end
        post '/:task_id/cancel' do
          user = authenticate!
          
          task = AppTask.find_by(task_id: params[:task_id])
          if task.blank?
            return render_error(4004, '任务不存在')
          end
          
          order = task.task_orders.find_by(order_no: params[:oid])
          if order.blank?
            return render_error(4004, '您还未抢到该任务')
          end
          
          if order.expired?
            return render_error(1008, '抢到的任务已经过期，不能取消')
          end
          
          if order.completed?
            return render_error(1009, '任务已经提交完成，不能取消')
          end
          
          if order.can_cancel?
            order.cancel
            render_json_no_data
          else
            render_error(1009, '不能重复取消任务')
          end
          
        end # end post cancel
        
        desc "提交任务"
        params do
          requires :token, type: String, desc: '用户认证Token'
          requires :oid,   type: String, desc: '任务流水号'
        end
        post '/:task_id/commit' do
          user = authenticate!
          
          task = AppTask.find_by(task_id: params[:task_id])
          if task.blank?
            return render_error(4004, '任务不存在')
          end
          
          order = task.task_orders.find_by(order_no: params[:oid])
          if order.blank?
            return render_error(4004, '任务订单不存在')
          end
          
          if order.expired?
            return render_error(1008, '抢到的任务已经过期，不能提交')
          end
          
          if order.canceled?
            return render_error(1010, '抢到的任务已经取消，不能提交')
          end
          
          if order.commited_at.blank?
            return render_error(1011, '您还未开始该任务，不能提交')
          end
          
          if order.commited_at > Time.zone.now
            return render_error(1011, '您的任务还未完成，不能提交')
          end
          
          if order.can_complete?
            order.complete
            render_json_no_data
          else
            render_error(1012, '不能重复提交任务')
          end
          
        end # end commit
        
      end # end resource
      
    end
  end
end