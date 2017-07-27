classdef FrameNo < vt.Component.TextBox & vt.Action.Dispatcher & vt.State.Listener
	properties
		actionType = @vt.Action.SetCurrentFrameNo;
	end
	
	methods
		function this = FrameNo(parent)
			p = vt.InputParser();
			p.addParent();
			p.parse(parent);
			
			this@vt.Component.TextBox(parent);
			this.setParameters('Enable', 'off');
			
			this.setCallback();
		end
		
		function [] = dispatchAction(this, source, ~)
			str = get(source, 'String');
			num = str2double(str);
			if (isempty(num) || isnan(num))
				this.setParameters('String', this.data);
				this.log.warning('Frame number must be numerical.');
			else
				this.data = str;
% 				this.action.data = num;
% 				dispatchAction@vt.Action.Dispatcher(this, source, evtdata);
				this.action.dispatch(num);
			end
		end
		
		function [] = onCurrentFrameNoChange(this, state)
			str = num2str(state.currentFrameNo);
			this.data = str;
			this.setParameters('String', str);
		end
		
		function [] = onVideoChange(this, ~)
			this.setParameters('Enable', 'on');
		end
	end
	
end




%%% TODO
%%%
%%% Right now, you're trying to decide whether you really need
%%% vt.Action.Factory, or even vt.Action.Dispatcher. There are a few reasons:
%%%
%%% 1. Since you can store objects or object handles in properties, you don't
%%%    need a Factory to convert strings into objects for you
%%% 2. If you *do* use objects/object handles in properties instead of strings,
%%%    then it's more transparent to future plug-in-makers how to give something
%%%    an action
%%% 3. It turns out you need a lot of flexibility with the data parameters
%%%    you're sending with your actions. Sometimes, data is changed long after
%%%    the handle was created. It's OK to make your action early, but
%%%    - you don't have to--you can make it on the fly whenever you need it
%%%    - even if you do, you'll still have to pass it a data argument right
%%%      before it fires
%%%
%%% On the other hand, you do have to register actions to vt.Action.Listener,
%%% which can be done when you're getting the action from a factory.
%%%
%%% You *could* merge the two.
%%% 1. Store the class handle in a property actionType
%%% 2. On class load, this.action = this.factory.createAndRegisterAction(...)
%%% 3. Set your data anytime--in the constructor, in the callback function,
%%%    wherever.
%%% 4. Dispatch the action in vt.Component.dispatchAction





















