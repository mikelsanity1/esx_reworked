local function CreateJobClass(jobInfo)
    jobInfo = ESXR.Ensure(jobInfo, {})

    local xJob = {
        id = ESXR.Ensure(jobInfo.id, 0),
        name = ESXR.Ensure(jobInfo.name, 'unknown'),
        label = ESXR.Ensure(jobInfo.label, 'Unknown'),
        whitelisted = ESXR.Ensure(jobInfo.whitelisted, false),
        grades = {}
    }

    if (ESXR.Jobs ~= nil and ESXR.Jobs[xJob.id] ~= nil) then
        return ESXR.Ensure(ESXR.Jobs[xJob.id], {})
    end

    for k, v in pairs(ESXR.Ensure(jobInfo.grades, {})) do
        v = ESXR.Ensure(v, {})

        local xGrade = {
            job_id = ESXR.Ensure(xJob.id, 0),
            grade = ESXR.Ensure(v.grade, 0),
            name = ESXR.Ensure(v.name, 'unknown'),
            label = ESXR.Ensure(v.label, 'Unknown'),
            salary = ESXR.Ensure(v.salary, 250)
        }

        xJob.grades[xGrade.grade] = xGrade
    end

    if (ESXR.Jobs == nil) then ESXR.Jobs = ESXR.Ensure(ESXR.Jobs, {}) end
    if (ESXR.References == nil) then ESXR.References = ESXR.Ensure(ESXR.References, {}) end
    if (ESXR.References.Jobs == nil) then ESXR.References.Jobs = ESXR.Ensure(ESXR.References.Jobs, {}) end

    ESXR.Jobs[xJob.id] = xJob
    ESXR.References.Jobs[xJob.name] = xJob.id

    return ESXR.Jobs[xJob.id]
end

local function CreateJobObject(jobId, gradeId)
    jobId = ESXR.Ensure(jobId, 0)
    gradeId = ESXR.Ensure(gradeId, 0)

    if (jobId <= 0) then
        return nil
    end

    ESXR.Jobs = ESXR.Ensure(ESXR.Jobs, {})

    local job = ESXR.Ensure(ESXR.Jobs[jobId], {})
    local grades = ESXR.Ensure(job.grades, {})
    local grade = ESXR.Ensure(grades[gradeId], {})

    return {
        id = ESXR.Ensure(job.id, 0),
        name = ESXR.Ensure(job.name, 'unknown'),
        label = ESXR.Ensure(job.label, 'Unknown'),
        whitelisted = ESXR.Ensure(job.whitelisted, false),
        grade = {
            grade = ESXR.Ensure(grade.grade, 0),
            name = ESXR.Ensure(grade.name, 'unknown'),
            label = ESXR.Ensure(grade.label, 'Unknown'),
            salary = ESXR.Ensure(grade.salary, 250)
        }
    }
end

_G.CreateJobClass = CreateJobClass
_G.CreateJobObject = CreateJobObject