local payInterval = 60000

QBCore = exports['qb-core']:GetCoreObject()

Config = {}
Config.Jobs = QBCore.Shared.Jobs

function payPlayers()
    for _, playerId in ipairs(GetPlayers()) do
        local numericId = tonumber(playerId)
        local xPlayer = QBCore.Functions.GetPlayer(numericId)

        if xPlayer then
            local job = xPlayer.PlayerData.job

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

function getPayAmount(jobName, jobGrade)
    local jobData = Config.Jobs[jobName]
    if jobData then
        if jobData.grades then
            local playerGrade = jobData.grades[tostring(jobGrade)]
            if playerGrade and playerGrade.payment then
                return playerGrade.payment
            end
        elseif jobData.salary then
            return jobData.salary
        end
    end
    return 0
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(payInterval)
        payPlayers()
    end
end)
