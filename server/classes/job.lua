local function CreateJobClass(jobInfo)
    jobInfo = ESR.Ensure(jobInfo, {})

    ---@class xJob
    local xJob = {
        __class = 'xJob',
        __type = 'xJob',
        id = ESR.Ensure(jobInfo.id, 0),
        name = ESR.Ensure(jobInfo.name, 'unknown'),
        label = ESR.Ensure(jobInfo.label, 'Unknown'),
        whitelisted = ESR.Ensure(jobInfo.whitelisted, false),
        grades = {}
    }

    if (ESR.Jobs ~= nil and ESR.Jobs[xJob.id] ~= nil) then
        return ESR.Ensure(ESR.Jobs[xJob.id], {})
    end

    for k, v in pairs(ESR.Ensure(jobInfo.grades, {})) do
        v = ESR.Ensure(v, {})

        local xGrade = {
            __class = 'xJobGrade',
            __type = 'xJobGrade',
            job_id = ESR.Ensure(xJob.id, 0),
            grade = ESR.Ensure(v.grade, 0),
            name = ESR.Ensure(v.name, 'unknown'),
            label = ESR.Ensure(v.label, 'Unknown'),
            salary = ESR.Ensure(v.salary, 250)
        }

        xJob.grades[xGrade.grade] = xGrade
    end

    if (ESR.Jobs == nil) then ESR.Jobs = ESR.Ensure(ESR.Jobs, {}) end
    if (ESR.References == nil) then ESR.References = ESR.Ensure(ESR.References, {}) end
    if (ESR.References.Jobs == nil) then ESR.References.Jobs = ESR.Ensure(ESR.References.Jobs, {}) end

    ESR.Jobs[xJob.id] = xJob
    ESR.References.Jobs[xJob.name] = xJob.id

    return ESR.Jobs[xJob.id]
end

local function CreateJobObject(jobId, gradeId)
    jobId = ESR.Ensure(jobId, 0)
    gradeId = ESR.Ensure(gradeId, 0)

    if (jobId <= 0) then
        return nil
    end

    if (ESR.Jobs == nil) then
        ESR.Jobs = ESR.Ensure(ESR.Jobs, {})
    end

    local job = ESR.Ensure(ESR.Jobs[jobId], {})
    local grades = ESR.Ensure(job.grades, {})
    local grade = ESR.Ensure(grades[gradeId], {})

    return {
        id = ESR.Ensure(job.id, 0),
        name = ESR.Ensure(job.name, 'unknown'),
        label = ESR.Ensure(job.label, 'Unknown'),
        whitelisted = ESR.Ensure(job.whitelisted, false),
        grade = {
            grade = ESR.Ensure(grade.grade, 0),
            name = ESR.Ensure(grade.name, 'unknown'),
            label = ESR.Ensure(grade.label, 'Unknown'),
            salary = ESR.Ensure(grade.salary, 250)
        }
    }
end

--- Assign local as global variable
_G.CreateJobClass = CreateJobClass
_G.CreateJobObject = CreateJobObject