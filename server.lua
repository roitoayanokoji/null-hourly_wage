local payInterval = 60000 -- 1分ごとに支払い（ミリ秒）

-- QBCoreの初期化
QBCore = exports['qb-core']:GetCoreObject()

-- Configテーブルの定義
Config = {}
Config.Jobs = QBCore.Shared.Jobs -- QBCoreからジョブデータを取得

-- プレイヤーにお金を振り込む関数
function payPlayers()
    for _, playerId in ipairs(GetPlayers()) do
        local numericId = tonumber(playerId) -- IDを数値に変換
        local xPlayer = QBCore.Functions.GetPlayer(numericId) -- 数値IDで取得

        if xPlayer then
            local job = xPlayer.PlayerData.job

            -- job.grade がテーブルの場合、level を取得
            if type(job.grade) == "table" then
                job.grade = job.grade.level or 0
            end

            local grade = job.grade
            local payAmount = getPayAmount(job.name, grade)

            if payAmount > 0 then
                xPlayer.Functions.AddMoney('cash', payAmount)
                TriggerClientEvent('QBCore:Notify', numericId, 'あなたは$' .. payAmount .. 'を受け取りました。')
            end
        end
    end
end

-- ジョブに基づいて時給を取得する関数
function getPayAmount(jobName, jobGrade)
    local jobData = Config.Jobs[jobName] -- jobs.luaからジョブデータを取得
    if jobData then
        if jobData.grades then
            local playerGrade = jobData.grades[tostring(jobGrade)] -- プレイヤーのグレードを取得
            if playerGrade and playerGrade.payment then
                return playerGrade.payment -- ジョブの時給を返す
            end
        elseif jobData.salary then
            return jobData.salary -- salaryが定義されている場合はそれを返す
        end
    end
    return 0 -- デフォルトは0
end

-- 一定の間隔で振り込む
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(payInterval)
        payPlayers()
    end
end)
