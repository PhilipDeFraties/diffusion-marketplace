require 'rails_helper'

describe 'Practice editor', type: :feature do
    describe 'About page' do
        before do
            @admin = User.create!(email: 'toshiro.hitsugaya@va.gov', password: 'Password123', password_confirmation: 'Password123', skip_va_validation: true, confirmed_at: Time.now, accepted_terms: true)
            @practice = Practice.create!(name: 'An awesome practice', slug: 'an-awesome-practice', approved: true, published: true, tagline: 'Test tagline', date_initiated: Date.new(2011, 12, 31), user: @admin)
            @admin.add_role(User::USER_ROLES[0].to_sym)
            login_as(@admin, :scope => :user, :run_callbacks => false)
            @origin_story = 'This innovation was founded on the basis of being awesome.'
            @creator_name = 'Grimmjow Jaegerjaquez'
            @creator_role = 'Sixth Espada'
            @creator_name_2 = 'Sosuke Aizen'
            @creator_role_2 = 'Leader of the Espada'
            @creator_field_name = 'practice[va_employees_attributes][0][name]'
            @creator_field_role = 'practice[va_employees_attributes][0][role]'
            @creator_field_name_2 = 'practice[va_employees_attributes][1][name]'
            @creator_field_role_2 = 'practice[va_employees_attributes][1][role]'
            @practice_main_email = 'test@mail.com'
            @email_field_name = 'practice[practice_emails_attributes][0][address]'
            @email_field_name_2 = 'practice[practice_emails_attributes][1][address]'
            visit practice_about_path(@practice)
        end

        it 'should be there' do
            expect(page).to be_accessible.according_to :wcag2a, :section508
            expect(page).to have_content('About')
            expect(page).to have_content('This section helps people understand how your innovation started and introduces the original team.')
        end

        def fill_in_origin_story_field
            fill_in('practice[origin_story]', with: @origin_story)
        end

        def first_creator_name_field_input
            all('.va-employee-name-input').first
        end

        def first_creator_role_field_input
            all('.va-employee-role').first
        end

        def first_creator_field
            find_all('.practice-editor-about-li').first
        end

        def last_creator_name_field_input
            all('.va-employee-name-input').last
        end

        def last_creator_role_field_input
            all('.va-employee-role').last
        end

        def last_creator_field
            find_all('.practice-editor-about-li').last
        end

        def save_button
            find('#practice-editor-save-button')
        end

        def fill_in_main_email_field
            fill_in('Main email address', with: @practice_main_email)
        end

        def first_cc_email_field_input
            all('.pe-address-input').first
        end

        def first_cc_email_field
            find_all('.practice-editor-contact-li').first
        end

        def last_cc_email_field_input
            all('.pe-address-input').last
        end

        def last_cc_email_field
            find_all('.practice-editor-contact-li').last
        end

        it 'should allow the user to update the origin story' do
            fill_in_main_email_field
            # create the origin story
            fill_in_origin_story_field
            save_button.click

            # see if the origin story shows up in the show view
            expect(page).to have_content('Origin story')
            within(:css, '#about') do
                expect(page).to have_content(@origin_story)
            end

            # Edit the origin story
            visit practice_about_path(@practice)
            fill_in('practice[origin_story]', with: 'This is an edited origin story.')
            save_button.click
            expect(page).to have_field('practice[origin_story]', with: "This is an edited origin story.")


            # check if the origin story with updated text shows up in the show view
            visit '/innovations/an-awesome-practice'
            expect(page).to have_content('This is an edited origin story.')
        end

        it 'should allow the user to update team members' do
            fill_in_main_email_field
            # create one team member and save
            fill_in_origin_story_field
            first_creator_name_field_input.set(@creator_name)
            first_creator_role_field_input.set(@creator_role)
            save_button.click
            expect(page).to have_content('Innovation was successfully updated')
            expect(page).to have_field('practice[origin_story]', with: @origin_story)
            expect(page).to have_field(@creator_field_name, with: @creator_name)
            expect(page).to have_field(@creator_field_role, with: @creator_role)

            # see if the team member shows up in the show view
            visit '/innovations/an-awesome-practice'
            expect(page).to have_content('Original team')
            expect(page).to have_content(@creator_name)
            expect(page).to have_content(@creator_role)

            # go back and edit the team member data
            visit practice_about_path(@practice)
            first_creator_name_field_input.set(@creator_name_2)
            first_creator_role_field_input.set(@creator_role_2)
            save_button.click
            expect(page).to have_field(@creator_field_name, with: @creator_name_2)
            expect(page).to have_field(@creator_field_role, with: @creator_role_2)

            # see if the team member with updated data shows up in the show view
            visit '/innovations/an-awesome-practice'
            expect(page).to have_content(@creator_name_2)
            expect(page).to have_content(@creator_role_2)

            # create another team member and save
            visit practice_about_path(@practice)
            within(:css, '#about_container') do
                click_link('Add another')
                last_creator_name_field_input.set(@creator_name)
                last_creator_role_field_input.set(@creator_role)
            end
            save_button.click

            within(:css, '.practice-editor-about-ul') do
                expect(page).to have_field(@creator_field_name, with: @creator_name_2)
                expect(page).to have_field(@creator_field_role, with: @creator_role_2)
                expect(page).to have_field(@creator_field_name_2, with: @creator_name)
                expect(page).to have_field(@creator_field_role_2, with: @creator_role)
            end

            # see if both team members show up in the show view
            visit '/innovations/an-awesome-practice'
            expect(page).to have_content('Original team')
            expect(page).to have_content(@creator_name)
            expect(page).to have_content(@creator_role)
            expect(page).to have_content(@creator_name_2)
            expect(page).to have_content(@creator_role_2)

            # delete first team member
            visit practice_about_path(@practice)
            input_field_id = first_creator_name_field_input[:id]
            within(first_creator_field) do
                click_link('Delete entry')
                expect(page).to_not have_selector("##{input_field_id}")
            end
            save_button.click

            # make sure the first team member does not show up in the show view
            visit '/innovations/an-awesome-practice'
            expect(page).to have_content('Original team')
            expect(page).to_not have_content(@creator_name_2)
            expect(page).to_not have_content(@creator_role_2)
            expect(page).to have_content(@creator_name)
            expect(page).to have_content(@creator_role)

            # delete the "second" team member
            visit practice_about_path(@practice)
            expect(page).to have_field(@creator_field_name, with: @creator_name)
            expect(page).to have_field(@creator_field_role, with: @creator_role)
            input_field_id = first_creator_name_field_input[:id]
            within(:css, '#about_container') do
                click_link('Add another')
            end
            within(:css, "##{first_creator_field[:id]}") do
                click_link('Delete entry')
                expect(page).to_not have_selector("##{input_field_id}")
            end
            save_button.click
            within(:css, '.practice-editor-about-ul') do
                expect(page).to_not have_selector("##{input_field_id}")
            end

            # make sure the "Original team" section was removed from the show view
            visit '/innovations/an-awesome-practice'
            expect(page).to_not have_content('Original team')
            expect(page).to_not have_content(@creator_name)
            expect(page).to_not have_content(@creator_role)
        end

        it 'should require the user to fill out the main email address field' do
            save_button.click
            email_message = page.find('.main-practice-email-input').native.attribute('validationMessage')
            expect(email_message).to eq('Please fill out this field.')
        end

        it 'should allow the user to update the email data on the page' do
            # create the main email address
            fill_in_main_email_field
            save_button.click

            # see if the main email shows up in the show view
            visit '/innovations/an-awesome-practice'
            expect(page).to have_content('Email')
            within(:css, '#contact') do
                expect(page).to have_content(@practice_main_email)
            end

            # Edit the main email
            visit practice_about_path(@practice)
            fill_in('Main email address', with: 'main_test@test.com')
            save_button.click
            expect(page).to have_field('Main email address', with: "main_test@test.com")


            # check if the main email with updated text shows up in the show view
            visit '/innovations/an-awesome-practice'
            expect(page).to have_content('main_test@test.com')

            # create one cc email and save
            visit practice_about_path(@practice)
            first_cc_email_field_input.set('test2@test.com')

            save_button.click
            expect(page).to have_field(@email_field_name, with: 'test2@test.com')

            # Edit the cc email
            first_cc_email_field_input.set('test22@test.com')
            save_button.click
            expect(page).to have_field(@email_field_name, with: 'test22@test.com')

            # create another cc email and save
            find('.add-practice-email-link').click
            last_cc_email_field_input.set('second_test@test.com')

            save_button.click
            expect(page).to have_field(@email_field_name, with: 'test22@test.com')
            expect(page).to have_field(@email_field_name_2, with: 'second_test@test.com')

            # delete first cc email
            input_field_id = first_cc_email_field_input[:id]
            within(first_cc_email_field) do
                click_link('Delete entry')
                expect(page).to_not have_selector("##{input_field_id}")
            end
            save_button.click
            within(:css, '.practice-editor-contact-ul') do
                expect(page).to have_field(@email_field_name, with: 'second_test@test.com')
            end

            # delete "second" cc email
            expect(page).to have_field(@email_field_name, with: 'second_test@test.com')
            input_field_id = first_cc_email_field_input[:id]
            find('.add-practice-email-link').click
            within(first_cc_email_field) do
                click_link('Delete entry')
                expect(page).to_not have_selector("##{input_field_id}")
            end
            save_button.click
            within(:css, '.practice-editor-contact-ul') do
                expect(page).to_not have_selector("##{input_field_id}")
            end
        end
    end
end
