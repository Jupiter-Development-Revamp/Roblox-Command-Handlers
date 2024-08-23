local user = game:GetService("Players").LocalPlayer;
local prefix = ";";

local function stringSimilarity(s1, s2)
	local m, n = #s1, #s2;
	local cost = {};

	for i = 0, m do cost[i] = {} end;
	for i = 0, m do cost[i][0] = i end;
	for j = 0, n do cost[0][j] = j end;

	for i = 1, m do
		for j = 1, n do
			local c = (s1:sub(i, i) == s2:sub(j, j)) and 0 or 1;
			cost[i][j] = math.min(cost[i - 1][j] + 1, cost[i][j - 1] + 1, cost[i - 1][j - 1] + c);
		end;
	end;

	return 1 - cost[m][n] / math.max(m, n);
end;

local cmds = {
	Test = {
		Aliases = {"test"};
		Func = function(input)
			print(table.concat(input, " "));
		end;
	};
};

game:GetService("TextChatService").SendingMessage:Connect(function(message)
	if game:GetService("Players"):GetPlayerByUserId(message.TextSource.UserId).Name ~= user.Name then return end;
	if message.Text:sub(1, #prefix) ~= prefix then return end;

	local args = message.Text:split(" ");
	local cmd = args[1]:sub(#prefix + 1):lower();
	table.remove(args, 1);

	local bestMatch, highestScore = nil, 0;

	for name, cmdData in pairs(cmds) do
		for _, alias in ipairs(cmdData.Aliases) do
			local similarity = stringSimilarity(cmd, alias:lower());
			if similarity > highestScore then
				highestScore = similarity;
				bestMatch = cmdData;
			end;
		end;
	end;

	if bestMatch and highestScore >= 0.7 then
		local success, error = pcall(bestMatch.Func, args);
		if not success then
			warn("Error executing command: " .. error);
		end;
	else
		warn("Invalid Command: " .. cmd);
	end;
end);
